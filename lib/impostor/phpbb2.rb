require 'rubygems'
require 'hpricot'
require 'mechanize'
require 'cgi'
require 'pp'

module WWW
  class Impostor
  
    ##
    # phpBB version of the Impostor
    #
    class Phpbb2 < WWW::Impostor

      ##
      # After initializing the parent a mechanize agent is created

      def initialize(config={})
        super(config)
        @agent = WWW::Mechanize.new
        @agent.user_agent = user_agent
        # jar is a yaml file
        @agent.cookie_jar.load(cookie_jar) if cookie_jar && File.exist?(cookie_jar)
        @message = nil
        @loggedin = false
      end

      ##
      # clean up the state of the library and log out

      def logout
        return unless @loggedin

        @agent.cookie_jar.save_as(cookie_jar) if cookie_jar
        save_topics

        @forum = nil
        @topic = nil
        @message = nil

        @loggedin = false
      end

      def new_topic(forum=@forum, subject=@subject, message=@message)
        raise PostError.new("forum not set") if forum.nil?
        raise PostError.new("topic name not given") if subject.nil?
        raise PostError.new("message not set") if message.nil?

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
        form = page.form('post')

        # set up the form and submit it
        button = form.buttons.with.name('post').first
        form.subject = subject
        form.message = message
        begin
          page = @agent.submit(form, button)
        rescue StandardError => err
          raise PostError.new(err)
        end

        # if the response is correct there will be a link that looks something like
        # Click <a href="http://localhost/phpbb2/viewtopic.php?p=29#29">Here</a> to view your message
        # MIKE TODO <meta http-equiv="refresh" content="3;url=viewtopic.php?p=29#29">
        #
        # this link needs to be clicked, the page it leads to will give us
        # the topic id that was created for the topic name that we created
        a = page.search("//span[@class='gen']//a").first
        raise PostError.new('unexpected new topic response') if a.nil?

        page = @agent.click(a)
        link = page.search("//link[@rel='prev']").first
        raise PostError.new('unexpected new topic response') if link.nil? || link['href'].nil?
        # t=XXX will be our new topic id, i.e.
        # <link rel="prev" href="http://localhost/phpBB2/viewtopic.php?t=5&amp;view=previous" title="View previous topic"
        
        begin
          u = URI.parse(link['href'])
          topic = CGI::parse(u.query)['t'][0]
          raise PostError.new('unexpected new topic response') if topic.nil?
        rescue StandardError => err
          raise PostError.new(err)
        end

        # save new topic id and topic name
        add_subject(forum, topic, subject)
        @forum=forum; @topic=topic; @subject=subject; @message=message
        true
      end

      ##
      # Attempt to post to the forum

      def post(forum = @forum, topic = @topic, message = @message)
        raise PostError.new("forum not set") if forum.nil?
        raise PostError.new("topic not set") if topic.nil?
        raise PostError.new("message not set") if message.nil?

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
        form = page.form('post')

        # set up the form and submit it
        button = form.buttons.with.name('post').first
        form.message = message
        begin
          page = @agent.submit(form, button)
        rescue StandardError => err
          raise PostError.new(err)
        end

        mes = page.search("//span[@class='gen']").last
        posted = mes.innerText =~ /Your message has been entered successfully./ rescue false
        if posted
          @forum=forum, @topic=topic, @subject=get_subject(forum,topic), @message=message
          return true
        end

        too_many = (mes.innerText =~ 
          /You cannot make another post so soon after your last; please try again in a short while./ rescue
          false)
        raise PostError.new("too many posts in too short amount of time") if too_many

        # false otherwise, should we raise an exception instead?
        false
      end

      ##
      # does the work of logging into phpbb

      def login
        return if @loggedin
  
        # get the login page
        page = fetch_login_page

        # return if we are already logged in from a cookie state
        return if logged_in?(page)

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
        form = page.forms
        form = page.forms.first if page.forms
        raise LoginError.new("unknown login page format") unless form
        
        button = page.forms.first.buttons.with.name('login').first
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
        mm = page.search("//a[@class='mainmenu']")
        return true if mm.last.innerText =~ /Log out \[ #{username} \]/ rescue false
        false
      end
 
    end
  end
end
