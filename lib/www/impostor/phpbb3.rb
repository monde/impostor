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
      @agent = Mechanize.new
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

    ##
    # make a new topic

    def new_topic(forum=@forum, subject=@subject, message=@message)
      raise PostError.new("forum not set") unless forum
      raise PostError.new("topic name not given") unless subject
      raise PostError.new("message not set") unless message

      login
      raise PostError.new("not logged in") unless @loggedin

      uri = posting_page
      uri.query = "mode=post&f=#{forum}"

      # get the submit form
      begin
        page = @agent.get(uri)
      rescue StandardError => err
        raise PostError.new(err)
      end

      form = page.form('postform') rescue nil
      raise PostError.new("post form not found") unless form
      button = form.buttons.detect{|b| b.name == 'post'}
      raise PostError.new("post form button not found") unless button

      # set up the form and submit it
      form['subject'] = subject
      form['message'] = message
      form['lastclick'] = (form['lastclick'].to_i - 60).to_s

      begin
        page = @agent.submit(form, button)
      rescue StandardError => err
        raise PostError.new(err)
      end

      # new topic will be current page uri since phpbb3 will 302 to the new
      # topic page, e.g.
      # http://example.com/forum/viewtopic.php?f=37&t=52
      topic = page.uri.query.split('&').detect{|a| a =~ /^t=/}.split('=').last.to_i rescue 0
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
      uri.query = "mode=reply&f=#{forum}&t=#{topic}"

      # get the submit form
      begin
        page = @agent.get(uri)
      rescue StandardError => err
        raise PostError.new(err)
      end

      form = page.form('postform') rescue nil
      button = form.buttons.with.name('post').first rescue nil
      raise PostError.new("post form not found") unless button && form

      # set up the form and submit it
      form.message = message
      form['lastclick'] = (form['lastclick'].to_i - 60).to_s

      begin
        page = @agent.submit(form, button)
      rescue StandardError => err
        raise PostError.new(err)
      end

      # new post will be in current page uri since phpbb3 will 302 to the new
      # post page post anchor, e.g.
      # http://example.com/forum/viewtopic.php?f=37&t=52&p=3725#p3725
      postid = page.uri.query.split('&').detect{|a| a =~ /^p=/}.split('=').last.to_i rescue 0
      raise PostError.new("message did not post") unless postid > 0

      @forum=forum; @topic=topic; @subject=get_subject(forum,topic); @message=message

      true
    end

    ##
    # Get the posting page for the application (specific to phpBB3)

    def posting_page
      URI.join(app_root, config[:posting_page])
    end

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

    ##
    # Checks if the agent is already logged by stored cookie

    def logged_in?(page)
      mm = page.search( "//a" ).detect{|a| a.inner_html =~ /Logout \[ #{username} \]/}
      mm ||= page.search( "//a" ).detect{|a| a['href'] =~ /\.\/ucp.php\?mode=logout/}

      mm.nil? ? false : true
    end

  end
end
