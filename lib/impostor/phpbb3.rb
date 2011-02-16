##
# phpBB3 version of the Impostor
#

class Impostor

  module Phpbb3

    ##
    # Additional configuration parameters for a Phpbb3 compatible agent:
    #
    # :posting_page
    #
    # Typical configuration parameters
    # { :type => :phpbb3,
    #   :app_root => 'http://example.com/forum/',
    #   :login_page => 'ucp.php?mode=login',
    #   :posting_page => 'posting.php',
    #   :user_agent => 'Windows IE 7',
    #   :username => 'myuser',
    #   :password => 'mypasswd' }

    module Auth

      ##
      # Checks if the agent is already logged by stored cookie

      def logged_in?(page)
        mm = page.search( "//a" ).detect{ | a| a.inner_html =~ /Logout \[ #{self.config.username} \]/ } ||
             page.search( "//a" ).detect{ |a| a['href'] =~ /\.\/ucp\.php\?mode=logout/ }

        not mm.nil?
      end

      ##
      # returns the login form from the login page

      def get_login_form(page)
        form = page.forms.detect { |form| form.action =~ /\/ucp\.php\?mode=login/ }
        raise Impostor::LoginError.new("unknown login page format") unless form
        form
      end

      ##
      # Sets the user name and pass word on the loing form.

      def set_username_and_password(form)
        form['username'] = self.config.username
        form['password'] = self.config.password
        form['login'] = 'Login'
        form['autologin'] = 'on'
        form
      end

    end

    module Post

      ##
      # return a uri used to fetch the reply page based on the forum, topic, and
      # message

      def get_reply_uri(forum, topic)
        uri = URI.join(self.config.app_root, self.config.config(:posting_page))
        uri.query = "mode=reply&f=#{forum}&t=#{topic}"
        uri
      end

      ##
      # return the form used for posting a message from the reply page

      def get_post_form(page)
        form = page.forms.detect { |form| form.action =~ /#{Regexp.escape(self.config.config(:posting_page))}/ }
        raise Impostor::PostError.new("unknown reply page format") unless form
        form
      end

      ##
      # set the message to reply with on the reply form

      def set_message(form, message)
        form.message = message
        form["post"] = "Submit"
        lastclick = form.lastclick || 60
        form["lastclick"] = (lastclick.to_i - 60).to_s
        form
      end

      ##
      # validate the result of posting the message form

      def validate_post_result(page)
        begin
          error_message = page_error_message(page)
          unless error_message.empty?
            raise StandardError.new("Message did not post, #{error_message}")
          end
          kv = page.links.collect{ |l| l.uri }.compact.
                          collect{ |l| l.query }.compact.
                          collect{ |q| q.split('&')}.flatten.
                          detect{|kv| kv =~ /^p=/ }
          postid = URI.unescape(kv).split('#').first.split('=').last.to_i
          raise StandardError.new("Message did not post.") if postid.zero?
          postid
        rescue StandardError => err
          raise Impostor::PostError.new(err)
        end
      end

      ##
      # Extract the error from a page
      def page_error_message(page)
        page.search(".//p[@class='error']").text
      end

    end

    module Topic

      ##
      # return a uri used to fetch the new topic page based on the forum, subject,
      # and message

      def get_new_topic_uri(forum, subject, message)
        uri = URI.join(self.config.app_root, self.config.config(:posting_page))
        uri.query = "mode=newtopic&f=#{forum}"
        uri
      end

      ##
      # Get the the new topic form on the page

      def get_new_topic_form(page)
        form = page.form('postform')
        raise Impostor::TopicError.new("unknown new topic page format") unless form
        form
      end

      ##
      # Set the subject and message on the new topic form

      def set_subject_and_message(form, subject, message)
        form.subject = subject
        form.message = message
        form.lastclick = (form.lastclick.to_i - 60).to_s
        form
      end

      ##
      # Validate the result of posting the new topic

      def validate_new_topic_result(page)
        #NOOP in phpbb3, #get_topic_from_result is the validation
        true
      end

      ##
      # Get the new topic identifier from the result page

      def get_topic_from_result(page)
        begin
          topic = page.uri.query.split('&').detect{|a| a =~ /^t=/}.split('=').last.to_i
          raise StandardError.new("new topic id not found") if topic.zero?
          topic
        rescue NoMethodError, StandardError => err
          raise Impostor::TopicError.new(err)
        end
      end

    end

  end
end
