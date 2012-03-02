##
# Web Wiz Forums version 7.9 of the Impostor
#

class Impostor

  module Wwf79

    ##
    # Additional configuration parameters for a Wwf79 compatible agent:
    #
    # :forum_posts_page
    # :post_message_page
    #
    # Typical configuration parameters
    # { :type => :wwf79,
    #   :app_root => 'http://example.com/forum/',
    #   :login_page => 'login_user.asp',
    #   :forum_posts_page => 'forum_posts.asp',
    #   :post_message_page => 'post_message_form.asp'
    #   :user_agent => 'Windows IE 7',
    #   :username => 'myuser',
    #   :password => 'mypasswd' }

    module Auth

      def login # :nodoc:
        Impostor.not_tested("Impostor::Wwf79::Auth", "login")
        super
      end

      ##
      # Checks if the agent is already logged by stored cookie

      def logged_in?(page)
        mm = page.search("//a[@class='nav']")
        !! mm.detect { |m| m.text =~ /Logout \[#{self.config.username}\]/ }
      end

      ##
      # returns the login form from the login page

      def get_login_form(page)
        form = page.form('frmLogin')
        raise Impostor::LoginError.new("unknown login page format") unless form
        form
      end

      ##
      # Sets the user name and pass word on the loing form.
      def set_username_and_password(form)
        button = Mechanize::Form::Button.new(form, 'Forum Login')
        form.add_button_to_query(button)
        form['name'] = self.config.username
        form['password'] = self.config.password
        form
      end

    end

    module Post

      def post(forum, topic, message) # :nodoc:
        Impostor.not_tested("Impostor::Wwf79::Post", "post")
        super
      end

      ##
      # return a uri used to fetch the reply page based on the forum, topic, and
      # message

      def get_reply_uri(forum, topic)
        uri = URI.join(self.config.app_root, self.config.config(:forum_posts_page))
        uri.query = "TID=#{topic}&TPN=10000"
        uri
      end

      ##
      # return the form used for posting a message from the reply page

      def get_post_form(page)
        form = page.form('frmAddMessage')
        raise Impostor::PostError.new("unknown reply page format") unless form
        form
      end

      ##
      # get post id from the result of posting the message form
      # FIXME this validation is copied into topic module as well

      def get_post_from_result(page)
        error = page.body =~ /Message Not Posted/
        if error

          # throttled
          throttled = "You have exceeded the number of posts permitted in the time span"
          too_many = page.body =~ /#{throttled}/
          raise Impostor::ThrottledError.new(throttled) if too_many

          # general error
          raise Impostor::PostError.new("There was an error making the post")
        end

        kv = page.links.collect{ |l| l.uri }.compact.
                        collect{ |l| l.query }.compact.
                        collect{ |q| q.split('&')}.flatten.
                        detect{|kv| kv =~ /^PID=/ }
        postid = URI.unescape(kv).split('#').first.split('=').last.to_i
        raise Impostor::PostError.new("Message did not post.") if postid.zero?
        postid
      end

    end

    module Topic

      def new_topic(forum, subject, message) # :nodoc:
        Impostor.not_tested("Impostor::Wwf79::Topic", "new_topic")
        super
      end

      ##
      # return a uri used to fetch the new topic page based on the forum, subject,
      # and message

      def get_new_topic_uri(forum, subject, message)
        uri = URI.join(self.config.app_root, self.config.config(:post_message_page))
        uri.query = "FID=#{forum}"
        uri
      end

      ##
      # Get the the new topic form on the page

      def get_new_topic_form(page)
        form = page.form('frmAddMessage')
        raise Impostor::TopicError.new("unknown new topic page format") unless form
        form
      end

      ##
      # Set the subject and message on the new topic form

      def set_subject_and_message(form, subject, message)
        form.subject = subject
        form.message = message
        form
      end

      ##
      # validate the result of posting the message form
      # FIXME this validation is copied into post module as well

      def validate_new_topic_result(page)
        error = page.body =~ /Message Not Posted/
        if error

          # throttled
          throttled = "You have exceeded the number of posts permitted in the time span"
          too_many = page.body =~ /#{throttled}/
          raise Impostor::ThrottledError.new(throttled) if too_many

          # general error
          raise Impostor::TopicError.new("There was an error making the post")
        end

        page
      end

      ##
      # Get the new topic identifier from the result page

      def get_topic_from_result(page)
        begin
          tid = page.form('frmAddMessage')['TID'].to_i
          raise StandardError.new("new topic id not found") if tid.zero?
          tid
        rescue StandardError => err
          raise Impostor::TopicError.new(err)
        end
      end

    end

  end
end
