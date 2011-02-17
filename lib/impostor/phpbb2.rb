##
# phpBB2 version of the Impostor
#

class Impostor

  module Phpbb2

    ##
    # Additional configuration parameters for a Phpbb2 compatible agent:
    #
    # :posting_page
    #
    # Typical configuration parameters
    # { :type => :phpbb2,
    #   :app_root => 'http://example.com/forum/',
    #   :login_page => 'login.php',
    #   :posting_page => 'posting.php',
    #   :user_agent => 'Windows IE 7',
    #   :username => 'myuser',
    #   :password => 'mypasswd' }

    module Auth

      ##
      # Checks if the agent is already logged by stored cookie

      def logged_in?(page)
        mm = page.search( "//a" ).detect{ | a| a.inner_html =~ /Log out \[ #{self.config.username} \]/ } ||
             page.search( "//a" ).detect{ |a| a['href'] =~ /\/login\.php\?mode=logout/ }

        not mm.nil?
      end

      ##
      # returns the login form from the login page

      def get_login_form(page)
        form = page.forms.detect { |form| form.action =~ /login\.php/ }
        raise Impostor::LoginError.new("unknown login page format") unless form
        form
      end

      ##
      # Sets the user name and pass word on the loing form.

      def set_username_and_password(form)
        form['username'] = self.config.username
        form['password'] = self.config.password
        form['autologin'] = 'on'
        form['login'] = 'Log in'
        form
      end

    end

    module Post

      ##
      # return a uri used to fetch the reply page based on the forum, topic, and
      # message

      def get_reply_uri(forum, topic)
        uri = URI.join(self.config.app_root, self.config.config(:posting_page))
        uri.query = "mode=reply&t=#{topic}"
        uri
      end

      ##
      # return the form used for posting a message from the reply page

      def get_post_form(page)
        form = page.forms.detect { |form| form.action =~ /#{Regexp.escape(self.config.config(:posting_page))}/ }
        raise Impostor::PostError.new("unknown reply page format#{page_message(page, ', ')}") unless form
        form
      end

      ##
      # set the message to reply with on the reply form

      def set_message(form, message)
        form.message = message
        form["post"] = "Submit"
        form
      end

      ##
      # validate the result of posting the message form

      def validate_post_result(page)
        message = page_message(page)
        if message =~ /Your message has been entered successfully./
          kv = page.links.collect{ |l| l.uri }.compact.
                          collect{ |l| l.query }.compact.
                          collect{ |q| q.split('&')}.flatten.
                          detect{|kv| kv =~ /^p=/ }
          postid = URI.unescape(kv).split('#').first.split('=').last.to_i
          raise Impostor::PostError.new("Message did not post.") if postid.zero?
          return postid
        end

        too_many = message =~ /You cannot make another post so soon after your last/

        if too_many
          raise Impostor::ThrottledError.new("too many posts in too short amount of time")
        else
          raise Impostor::PostError.new("message did not post")
        end
      end

      def page_message(page, prepend = '')
        message = page.search("//span[@class='gen']").last || ''
        message = message.text if message.respond_to?(:text)
        prepend = '' if message.empty?
        "#{prepend}#{message}"
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
        form = page.form('post')
        raise Impostor::TopicError.new("unknown new topic page format") unless form
        form
      end

      ##
      # Set the subject and message on the new topic form

      def set_subject_and_message(form, subject, message)
        form.subject = subject
        form.message = message
        form.disable_html = nil
        form.disable_bbcode = 'on'
        form.disable_smilies = 'on'
        form
      end

      ##
      # Validate the result of posting the new topic

      def validate_new_topic_result(page)
        #NOOP in phpbb2, #get_topic_from_result is the validation
        true
      end

      ##
      # Get the new topic identifier from the result page

      def get_topic_from_result(page)
        # if the response is correct there will be a meta link that looks something like
        # <meta http-equiv="refresh" content="3;url=viewtopic.php?p=29#29">
        # this link needs to be followed, the page it leads to will give us
        # the topic id that was created for the topic name that we created
        begin
          url = page.search("//meta[@http-equiv='refresh']").attr('content')
          url = /url=(.*)/.match(url)[1]
          raise StandardError.new('unexpected new topic response from refresh') unless url

          url = URI.join(self.config.app_root, url)
          page = self.config.agent.get(url)
          link = page.search("//link[@rel='prev']").first['href']
          raise StandardError.new('unexpected new topic response from link prev') unless link

          # t=XXX will be our new topic id, i.e.
          # <link rel="prev" href="http://localhost/phpBB2/viewtopic.php?t=5&amp;view=previous" title="View previous topic"
          href = URI.parse(link)
          topic = CGI::parse(href.query)['t'].first.to_i
          raise StandardError.new('unexpected new topic ID') unless topic > 0
          topic
        rescue NoMethodError, StandardError => err
          raise Impostor::TopicError.new(err)
        end
      end

    end

  end
end
