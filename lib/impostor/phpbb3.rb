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
        form = page.form('postform')
        raise Impostor::PostError.new("unknown reply page format") unless form
        form
      end

      ##
      # validate the result of posting the message form

      def validate_post_result(page)
        begin

          postid = page.uri.query.split('&').detect{ |a| a =~ /^p=/ }.split('=').last.to_i
          raise StandardError.new("message did not post") unless postid > 0
        rescue StandardError => err
          raise Impostor::PostError.new(err)
        end
        postid
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
        #NOOP in phpbb3
        true
      end

      # ##
      # # make a new topic

      # def new_topic(forum=@forum, subject=@subject, message=@message)

      #   super

      #   form = page.form('postform') rescue nil
      #   raise PostError.new("post form not found") unless form
      #   button = form.buttons.detect{|b| b.name == 'post'}
      #   raise PostError.new("post form button not found") unless button

      #   # set up the form and submit it
      #   form['subject'] = subject
      #   form['message'] = message
      #   form['lastclick'] = (form['lastclick'].to_i - 60).to_s

      #   begin
      #     page = @agent.submit(form, button)
      #   rescue StandardError => err
      #     raise PostError.new(err)
      #   end

      #   # new topic will be current page uri since phpbb3 will 302 to the new
      #   # topic page, e.g.
      #   # http://example.com/forum/viewtopic.php?f=37&t=52
      #   topic = page.uri.query.split('&').detect{|a| a =~ /^t=/}.split('=').last.to_i rescue 0
      #   raise PostError.new('unexpected new topic ID') unless topic > 0

      #   # save new topic id and topic name
      #   add_subject(forum, topic, subject)
      #   @forum=forum; @topic=topic; @subject=subject; @message=message
      #   true
      # end

    end

  end
end
