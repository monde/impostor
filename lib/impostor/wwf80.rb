require 'rubygems'
require 'hpricot'
require 'mechanize'
require 'logger'
require 'cgi'

##
# Web Wiz Forums version 8.0 of the Impostor
#

class WWW::Impostor
  
  class Wwf80 < WWW::Impostor

    ##
    # After initializing the parent a mechanize agent is created

    def initialize(config={})
      super(config)
      @agent = WWW::Mechanize.new
      @agent.user_agent_alias = user_agent
      # jar is a yaml file
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

    def new_topic(forum=@forum, subject=@subject, message=@message)
      raise PostError.new("forum not set") unless forum
      raise PostError.new("topic name not given") unless subject
      raise PostError.new("message not set") unless message

      login
      raise PostError.new("not logged in") unless @loggedin

      uri = new_topic_page
      uri.query = "FID=#{forum}"

      # get the submit form
      begin
        page = @agent.get(uri)
      rescue StandardError => err
        raise PostError.new(err)
      end
      form = page.form('frmMessageForm')

      # set up the form and submit it
      button = form.buttons.with.name('Submit').first
      form.subject = subject
      form.message = message
      begin
        page = @agent.submit(form, button)
      rescue StandardError => err
        raise PostError.new(err)
      end

      error = page.search("//table[@class='errorTable']")
      if error
        msgs = error.search("//td")

        # throttled
        too_many = (msgs.last.innerText =~ 
        /You have exceeded the number of posts permitted in the time span/ rescue
        false)
        raise ThrottledError.new(msgs.last.innerText.gsub(/\s+/m,' ').strip) if too_many

        # general error
        had_error = (error.last.innerText =~ 
        /Error: Message Not Posted/ rescue
        false)
        raise PostError.new(error.last.innerText.gsub(/\s+/m,' ').strip) if had_error
      end

      # look up the new topic id
      form = page.form('frmMessageForm')
      topic = form['TID'].to_i

      # save new topic id and topic name
      add_subject(forum, topic, subject)

      @forum=forum; @topic=topic; @subject=get_subject(forum,topic); @message=message
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

      uri = new_reply_page
      uri.query = "TID=#{topic}"

      # get the submit form
      begin
        page = @agent.get(uri)
      rescue StandardError => err
        raise PostError.new(err)
      end
      form = page.form('frmMessageForm')

      # set up the form and submit it
      button = form.buttons.with.name('Submit').first
      form.message = message
      begin
        page = @agent.submit(form, button)
      rescue StandardError => err
        raise PostError.new(err)
      end

      error = page.search("//table[@class='errorTable']")
      if error
        msgs = error.search("//td")

        # throttled
        too_many = (msgs.last.innerText =~ 
        /You have exceeded the number of posts permitted in the time span/ rescue
        false)
        raise ThrottledError.new(msgs.last.innerText.gsub(/\s+/m,' ').strip) if too_many

        # general error
        had_error = (error.last.innerText =~ 
        /Error: Message Not Posted/ rescue
        false)
        raise PostError.new(error.last.innerText.gsub(/\s+/m,' ').strip) if had_error
      end

      @forum=forum; @topic=topic; @subject=get_subject(forum,topic); @message=message
      return true
    end

    ##
    # Get the new reply page for the application (specific to WWF8.0)
  
    def new_reply_page
      URI.join(app_root, @config[:new_reply_page])
    end

    ##
    # Get the new topic page for the application (specific to WWF8.0)
  
    def new_topic_page
      URI.join(app_root, @config[:new_topic_page])
    end
  
    ##
    # does the work of logging into WWF 8.0

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
      
      button = form.buttons.with.name('Submit').first
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
