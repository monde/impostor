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
    # :app_root => 'http://example.com/forum/',
    # :login_page => 'login_user.asp',
    # :new_reply_page => 'new_reply_form.asp',
    # :new_topic_page => 'new_topic_form.asp',
    # :user_agent => 'Windows IE 7',
    # :username => 'myuser',
    # :password => 'mypasswd' }

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
        URI.join(self.config.app_root, self.config.config(:new_reply_page))
      end

      #  ##
      #  # Attempt to post to the forum

      #  def post(forum = @forum, topic = @topic, message = @message)
      #    raise PostError.new("forum not set") unless forum
      #    raise PostError.new("topic not set") unless topic
      #    raise PostError.new("message not set") unless message

      #    login
      #    raise PostError.new("not logged in") unless @loggedin

      #    uri = new_reply_page
      #    uri.query = "TID=#{topic}"

      #    # get the submit form
      #    begin
      #      page = @agent.get(uri)
      #    rescue StandardError => err
      #      raise PostError.new(err)
      #    end
      #    check_and_raise_if_error(page)

      #    form = page.form('frmMessageForm') rescue nil
      #    button = form.buttons.with.name('Submit').first rescue nil
      #    raise PostError.new("post form not found") unless button && form

      #    # set up the form and submit it
      #    form.message = message
      #    begin
      #      page = @agent.submit(form, button)
      #    rescue StandardError => err
      #      raise PostError.new(err)
      #    end
      #    check_and_raise_if_error(page)

      #    @forum=forum; @topic=topic; @subject=get_subject(forum,topic); @message=message
      #    return true
      #  end

      #  ##
      #  # Get the new reply page for the application (specific to WWF8.0)

      #  def new_reply_page
      #    URI.join(app_root, config(:new_reply_page))
      #  end
    end

    module Topic
      #  def _new_topic_form_query(forum)
      #    uri = new_topic_page
      #    uri.query = "FID=#{forum}"
      #    uri
      #  end

      #  def _new_topic_check_topic_form(page)
      #    check_and_raise_if_error(page)
      #  end

      #  def _new_topic_validate_topic_form(page)
      #    form = page.form('frmMessageForm') rescue nil
      #    button = form.buttons.with.name('Submit').first rescue nil
      #    raise PostError.new("post form not found") unless button && form
      #    form
      #  end

      #  def _new_topic_set_subject_and_message(form, subject, message)
      #    raise 'not implemented'
      #  end

      #  def new_topic(forum=@forum, subject=@subject, message=@message)

      #    super

      #    # set up the form and submit it
      #    form.subject = subject
      #    form.message = message

      #    begin
      #      page = @agent.submit(form, button)
      #    rescue StandardError => err
      #      raise PostError.new(err)
      #    end
      #    check_and_raise_if_error(page)

      #    # look up the new topic id
      #    form = page.form('frmMessageForm') rescue nil
      #    topic = form['TID'].to_i rescue 0
      #    raise PostError.new('unexpected new topic ID') if topic < 1

      #    # save new topic id and topic name
      #    add_subject(forum, topic, subject)

      #    @forum=forum; @topic=topic; @subject=subject; @message=message
      #    return true
      #  end

      #  ##
      #  # Get the new topic page for the application (specific to WWF8.0)

      #  def new_topic_page
      #    URI.join(app_root, config(:new_topic_page))
      #  end
    end

      #  protected

      #  ##
      #  # does the work of posting the login form

      #  def check_and_raise_if_error(page)
      #    error = page.search("//table[@class='errorTable']")
      #    if error
      #      msgs = error.search("//td")

      #      # throttled
      #      too_many = (msgs.last.text =~
      #      /You have exceeded the number of posts permitted in the time span/ rescue
      #      false)
      #      raise ThrottledError.new(msgs.last.text.gsub(/\s+/m,' ').strip) if too_many

      #      # general error
      #      had_error = (error.last.text =~
      #      /Error: Message Not Posted/ rescue
      #      false)
      #      raise PostError.new(error.last.text.gsub(/\s+/m,' ').strip) if had_error
      #    end
      #  end
  end
end
