##
# Web Wiz Forums version 8.0 of the Impostor
#

class Impostor

  module Wwf80

    ##
    # Additional configuration parameters for a Wwf80 compatible agent:
    #
    # :new_reply_page
    # :new_topic_page
    #
    # Typical configuration parameters
    # { :type => :wwf80,
    #   :app_root => 'http://example.com/forum/',
    #   :login_page => 'login_user.asp',
    #   :new_reply_page => 'new_reply_form.asp',
    #   :new_topic_page => 'new_topic_form.asp',
    #   :user_agent => 'Windows IE 7',
    #   :username => 'myuser',
    #   :password => 'mypasswd' }

    module Auth

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
        form['name'] = self.config.username
        form['password'] = self.config.password
        form
      end

      ##
      # given the state of the page, are we logged in to the forum?

      def logged_in?(page)
        mm = page.search("//a[@class='nav']")
        !! mm.detect { |m| m.text =~ /Logout \[#{self.config.username}\]/ }
      end

    end

    module Post

      ##
      # return a uri used to fetch the reply page based on the forum, topic, and
      # message

      def get_reply_uri(forum, topic)
        uri = URI.join(self.config.app_root, self.config.config(:new_reply_page))
        uri.query = "TID=#{topic}"
        uri
      end

      ##
      # return the form used for posting a message from the reply page

      def get_post_form(page)
        form = page.form('frmMessageForm')
        raise Impostor::PostError.new("unknown reply page format") unless form
        form
      end

      ##
      # validate the result of posting the message form
      # FIXME this validation is copied into topic module as well

      def validate_post_result(page)
         error = page.search("//table[@class='errorTable']")
         if error
           msgs = error.search("//td")

           # throttled
           too_many = (msgs.last.text =~
           /You have exceeded the number of posts permitted in the time span/ rescue
           false)
           raise ThrottledError.new(msgs.last.text.gsub(/\s+/m,' ').strip) if too_many

           # general error
           had_error = (error.last.text =~
           /Error: Message Not Posted/ rescue
           false)
           raise PostError.new(error.last.text.gsub(/\s+/m,' ').strip) if had_error
         end
         true
      end

    end

    module Topic

      ##
      # return a uri used to fetch the new topic page based on the forum, subject,
      # and message

      def get_new_topic_uri(forum, subject, message)
        uri = URI.join(self.config.app_root, self.config.config(:new_topic_page))
        uri.query = "FID=#{forum}"
        uri
      end

      ##
      # Get the the new topic form on the page

      def get_new_topic_form(page)
        form = page.form('frmMessageForm')
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
      # Validate the result of posting the new topic
      # FIXME this validation is copied into post module as well

      def validate_new_topic_result(page)
         error = page.search("//table[@class='errorTable']")
         if error
           msgs = error.search("//td")

           # throttled
           too_many = (msgs.last.text =~
           /You have exceeded the number of posts permitted in the time span/ rescue
           false)
           raise ThrottledError.new(msgs.last.text.gsub(/\s+/m,' ').strip) if too_many

           # general error
           had_error = (error.last.text =~
           /Error: Message Not Posted/ rescue
           false)
           raise TopicError.new(error.last.text.gsub(/\s+/m,' ').strip) if had_error
         end
         true
      end

      ##
      # Get the new topic identifier from the result page

      def get_topic_from_result(page)
        begin
          tid = page.form('frmMessageForm')['TID'].to_i
          raise StandardError.new("new topic id not found") if tid.zero?
          tid
        rescue StandardError => err
          raise Impostor::TopicError.new(err)
        end
      end

    end

  end
end
