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
        button = Mechanize::Form::Button.new('Submit', 'Forum Login')
        form.add_button_to_query(button)
        form['name'] = self.config.username
        form['password'] = self.config.password
        form
      end

    end

    module Post

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
      # validate the result of posting the message form

      def validate_post_result(page)
        error = page.body =~ /Message Not Posted/
        if error

          # throttled
          throttled = "You have exceeded the number of posts permitted in the time span"
          too_many = page.body =~ /#{throttled}/
          raise Impostor::ThrottledError.new(throttled) if too_many

          # general error
          raise Impostor::PostError.new("There was an error making the post")
        end

        true
      end

    end

    module Topic
    end

    #  ##
    #  # create a new topic

    #  def new_topic(forum=@forum, subject=@subject, message=@message)

    #    super

    #    form = page.form('frmAddMessage') rescue nil
    #    button = form.buttons.with.name('Submit').first rescue nil
    #    raise PostError.new("post form not found") unless button && form

    #    # set up the form and submit it
    #    form.subject = subject
    #    form.message = message
    #    begin
    #      page = @agent.submit(form, button)
    #    rescue StandardError => err
    #      raise PostError.new(err)
    #    end

    #    error = page.body =~ /Message Not Posted/
    #    if error

    #      # throttled
    #      throttled = "You have exceeded the number of posts permitted in the time span"
    #      too_many = page.body =~ /#{throttled}/
    #      raise ThrottledError.new(throttled) if too_many

    #      # general error
    #      raise PostError.new("There was an error creating the topic")
    #    end

    #    # look up the new topic id
    #    form = page.form('frmAddMessage') rescue nil
    #    topic = form['TID'].to_i rescue 0
    #    raise PostError.new('unexpected new topic ID') if topic < 1

    #    # save new topic id and topic name
    #    add_subject(forum, topic, subject)
    #    @forum=forum; @topic=topic; @subject=subject; @message=message
    #    return true
    #  end

  end
end
