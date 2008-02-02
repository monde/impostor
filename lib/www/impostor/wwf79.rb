require 'rubygems'
require 'hpricot'
gem 'mechanize', '>= 0.7.0'
require 'mechanize'
require 'cgi'

##
# Web Wiz Forums version 7.9 of the Impostor
#

class WWW::Impostor
  
  class Wwf79 < WWW::Impostor

    ##
    # After initializing the parent a mechanize agent is created
    #
    # Additional configuration parameters:
    #
    # :forum_posts_page
    # :post_message_page
    #
    # Typical configuration parameters
    # { :type => :wwf79,
    # :app_root => 'http://example.com/forum/',
    # :login_page => 'login_user.asp',
    # :forum_posts_page => 'forum_posts.asp',
    # :post_message_page => 'post_message_form.asp'
    # :user_agent => 'Windows IE 7',
    # :username => 'myuser',
    # :password => 'mypasswd' }

    def initialize(config={})
      super(config)
      @agent = WWW::Mechanize.new
      @agent.user_agent_alias = user_agent
      @agent.cookie_jar.load(cookie_jar) if cookie_jar && File.exist?(cookie_jar)
      @message = nil
      @loggedin = false
    end

    ##
    # clean up the state of the library and log out

    def logout
      return false unless @loggedin

      @agent.cookie_jar.save_as(cookie_jar) if cookie_jar
      save_topics

      @forum = nil
      @topic = nil
      @message = nil

      @loggedin = false
      true
    end

    ##
    # create a new topic

    def new_topic(forum=@forum, subject=@subject, message=@message)
      raise PostError.new("forum not set") unless forum
      raise PostError.new("topic name not given") unless subject
      raise PostError.new("message not set") unless message

      login
      raise PostError.new("not logged in") unless @loggedin

      uri = post_message_page
      uri.query = "FID=#{forum}"

      # get the submit form
      begin
        page = @agent.get(uri)
      rescue StandardError => err
        raise PostError.new(err)
      end
      form = page.form('frmAddMessage') rescue nil
      button = form.buttons.with.name('Submit').first rescue nil
      raise PostError.new("post form not found") unless button && form

      # set up the form and submit it
      form.subject = subject
      form.message = message
      begin
        page = @agent.submit(form, button)
      rescue StandardError => err
        raise PostError.new(err)
      end

      error = page.body =~ /Message Not Posted/
      if error

        # throttled
        throttled = "You have exceeded the number of posts permitted in the time span"
        too_many = page.body =~ /#{throttled}/
        raise ThrottledError.new(throttled) if too_many

        # general error
        raise PostError.new("There was an error creating the topic")
      end

      # look up the new topic id
      form = page.form('frmAddMessage') rescue nil
      topic = form['TID'].to_i rescue 0
      raise PostError.new('unexpected new topic ID') if topic < 1

      # save new topic id and topic name
      add_subject(forum, topic, subject)
      @forum=forum; @topic=topic; @subject=subject; @message=message
      return true
    end

    ##
    # Attempt to post to the forum

    def post(forum = @forum, topic = @topic, message = @message)
      raise PostError.new("forum not set") unless forum
      raise PostError.new("topic not set") unless topic
      raise PostError.new("message not set") unless message

      login
      raise PostError.new("not logged in") unless @loggedin

      uri = forum_posts_page
      uri.query = "TID=#{topic}&TPN=10000"

      # get the submit form
      begin
        page = @agent.get(uri)
      rescue StandardError => err
        raise PostError.new(err)
      end
      form = page.form('frmAddMessage') rescue nil
      button = form.buttons.with.name('Submit').first rescue nil
      raise PostError.new("post form not found") unless button && form

      # set up the form and submit it
      form.message = message
      begin
        page = @agent.submit(form, button)
      rescue StandardError => err
        raise PostError.new(err)
      end

      error = page.body =~ /Message Not Posted/
      if error

        # throttled
        throttled = "You have exceeded the number of posts permitted in the time span"
        too_many = page.body =~ /#{throttled}/
        raise ThrottledError.new(throttled) if too_many

        # general error
        raise PostError.new("There was an error making the post")
      end

      @forum=forum; @topic=topic; @subject=get_subject(forum,topic); @message=message
      return true
    end

    ##
    # Get the new posts page for the application (specific to WWF7.9)
  
    def forum_posts_page
      URI.join(app_root, @config[:forum_posts_page])
    end

    ##
    # Get the new topic page for the application (specific to WWF7.9)
  
    def post_message_page
      URI.join(app_root, @config[:post_message_page])
    end
  
    ##
    # does the work of logging into WWF 7.9

    def login
      return true if @loggedin

      # get the login page
      page = fetch_login_page

      # return if we are already logged in from a cookie state
      return true if logged_in?(page)

      # setup the form and submit
      form, button = login_form_and_button(page)
      page = post_login(form, button)

      # set up the rest of the state if we are logged in
      @loggedin = logged_in?(page)
      load_topics if @loggedin

      @loggedin
    end

    def version
      @version ||= self.class.to_s
    end

    protected

    ##
    # does the work of posting the login form

    def post_login(form, button)
      begin
        page = @agent.submit(form, button)
      rescue StandardError => err
        raise LoginError.new(err)
      end
    end

    ##
    # returns the login form and its button from the login page

    def login_form_and_button(page)
      form = page.forms.with.name('frmLogin').first rescue nil
      raise LoginError.new("unknown login page format") unless form

      button = WWW::Mechanize::Form::Button.new('Submit', 'Forum Login')
      form.add_button_to_query(button)
      form['name'] = username
      form['password'] = password
      return form, button
    end

    ##
    # fetches the login page

    def fetch_login_page
      begin
        page = @agent.get(login_page)
      rescue StandardError => err
        raise LoginError.new(err)
      end
    end

    ##
    # Checks if the agent is already logged by stored cookie

    def logged_in?(page)
      mm = page.search("//a[@class='nav']")
      return false unless mm
      mm.each do |m|
        return true if (m.innerText =~ /Logout \[#{username}\]/ rescue false)
      end
      false
    end
  end
end
