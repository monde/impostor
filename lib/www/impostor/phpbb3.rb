require 'rubygems'
require 'hpricot'
gem 'mechanize', '>= 0.7.0'
require 'mechanize'
require 'cgi'

##
# phpBB3 version of the Impostor
#

class WWW::Impostor
  
  class Phpbb3 < WWW::Impostor

    ##
    # After initializing the parent a mechanize agent is created
    #
    # Additional configuration parameters:
    #
    # :posting_page
    #
    # Typical configuration parameters
    # { :type => :phpbb3,
    # :app_root => 'http://example.com/forum/',
    # :login_page => 'ucp.php?mode=login',
    # :posting_page => 'posting.php',
    # :user_agent => 'Windows IE 7',
    # :username => 'myuser',
    # :password => 'mypasswd' }

    def initialize(config={})
      super(config)
      @agent = WWW::Mechanize.new
      @agent.user_agent_alias = user_agent
      # jar is a yaml file
      @agent.cookie_jar.load(cookie_jar) if cookie_jar && File.exist?(cookie_jar)
      @message = nil
      @loggedin = false
    end

=begin
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
    # make a new topic

    def new_topic(forum=@forum, subject=@subject, message=@message)
      raise PostError.new("forum not set") unless forum
      raise PostError.new("topic name not given") unless subject
      raise PostError.new("message not set") unless message

      login
      raise PostError.new("not logged in") unless @loggedin

      uri = posting_page
      uri.query = "mode=newtopic&f=#{forum}"

      # get the submit form
      begin
        page = @agent.get(uri)
      rescue StandardError => err
        raise PostError.new(err)
      end

      form = page.form('post') rescue nil
      button = form.buttons.with.name('post').first rescue nil
      raise PostError.new("post form not found") unless button && form

      # set up the form and submit it
      form.subject = subject
      form.message = message
      form['disable_html'] = nil
      form['disable_bbcode'] = 'on'
      form['disable_smilies'] = 'on'
      begin
        page = @agent.submit(form, button)
      rescue StandardError => err
        raise PostError.new(err)
      end

      # if the response is correct there will be a meta link that looks something like
      # <meta http-equiv="refresh" content="3;url=viewtopic.php?p=29#29">
      #
      # this link needs to be followed, the page it leads to will give us
      # the topic id that was created for the topic name that we created
      a = (page.search("//meta[@http-equiv='refresh']").attr('content') rescue nil)
      a = (/url=(.*)/.match(a)[1] rescue nil)
      raise PostError.new('unexpected new topic response from refresh') unless a

      a = URI.join(app_root, a)
      page = @agent.get(a)
      link = (page.search("//link[@rel='prev']").first['href'] rescue nil)
      raise PostError.new('unexpected new topic response from link prev') unless link

      # t=XXX will be our new topic id, i.e.
      # <link rel="prev" href="http://localhost/phpBB2/viewtopic.php?t=5&amp;view=previous" title="View previous topic"
      u = (URI.parse(link) rescue nil)
      topic = (CGI::parse(u.query)['t'][0] rescue nil)
      topic = topic.to_i
      raise PostError.new('unexpected new topic ID') unless topic > 0

      # save new topic id and topic name
      add_subject(forum, topic, subject)
      @forum=forum; @topic=topic; @subject=subject; @message=message
      true
    end

    ##
    # Attempt to post to the forum

    def post(forum = @forum, topic = @topic, message = @message)
      raise PostError.new("forum not set") unless forum
      raise PostError.new("topic not set") unless topic
      raise PostError.new("message not set") unless message

      login
      raise PostError.new("not logged in") unless @loggedin

      uri = posting_page
      uri.query = "mode=reply&t=#{topic}"

      # get the submit form
      begin
        page = @agent.get(uri)
      rescue StandardError => err
        raise PostError.new(err)
      end

      form = page.form('post') rescue nil
      button = form.buttons.with.name('post').first rescue nil
      raise PostError.new("post form not found") unless button && form

      # set up the form and submit it
      form.message = message
      form['disable_html'] = nil
      form['disable_bbcode'] = 'on'
      form['disable_smilies'] = 'on'
      begin
        page = @agent.submit(form, button)
      rescue StandardError => err
        raise PostError.new(err)
      end

      mes = page.search("//span[@class='gen']").last
      posted = mes.innerText =~ /Your message has been entered successfully./ rescue false
      if posted
        @forum=forum; @topic=topic; @subject=get_subject(forum,topic); @message=message
        return true
      end

      too_many = (mes.innerText =~ 
        /You cannot make another post so soon after your last; please try again in a short while./ rescue
        false)
      raise ThrottledError.new("too many posts in too short amount of time") if too_many

      # false otherwise, should we raise an exception instead?
      false
    end

    ##
    # Get the posting page for the application (specific to phpBB3)
  
    def posting_page
      URI.join(app_root, config[:posting_page])
    end
=end
  
    ##
    # does the work of logging into phpbb

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
      form = page.forms.first rescue nil
      raise LoginError.new("unknown login page format") unless form
      
      button = form.buttons.with.name('login').first
      form['username'] = username
      form['password'] = password
      form['autologin'] = 'on'

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

=begin
    ##
    # Checks if the agent is already logged by stored cookie

    def logged_in?(page)
      mm = page.search("//a[@class='mainmenu']")
      return false unless mm
      mm.each do |m|
        return true if (m.innerText =~ /Log out \[ #{username} \]/ rescue false)
      end
      false
    end
=end

  end
end
