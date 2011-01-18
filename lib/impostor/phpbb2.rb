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
    # :app_root => 'http://example.com/forum/',
    # :login_page => 'login.php',
    # :posting_page => 'posting.php',
    # :user_agent => 'Windows IE 7',
    # :username => 'myuser',
    # :password => 'mypasswd' }

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
        form
      end

    end

    module Post
    end

    module Topic
    end

    #  def _new_topic_form_query(forum)
    #    uri = posting_page
    #    uri.query = "mode=newtopic&f=#{forum}"
    #    uri
    #  end

    #  ##
    #  # make a new topic

    #  def new_topic(forum=@forum, subject=@subject, message=@message)

    #    super

    #    form = page.form('post') rescue nil
    #    button = form.buttons.with.name('post').first rescue nil
    #    raise PostError.new("post form not found") unless button && form

    #    # set up the form and submit it
    #    form.subject = subject
    #    form.message = message
    #    form['disable_html'] = nil
    #    form['disable_bbcode'] = 'on'
    #    form['disable_smilies'] = 'on'
    #    begin
    #      page = @agent.submit(form, button)
    #    rescue StandardError => err
    #      raise PostError.new(err)
    #    end

    #    # if the response is correct there will be a meta link that looks something like
    #    # <meta http-equiv="refresh" content="3;url=viewtopic.php?p=29#29">
    #    #
    #    # this link needs to be followed, the page it leads to will give us
    #    # the topic id that was created for the topic name that we created
    #    a = (page.search("//meta[@http-equiv='refresh']").attr('content') rescue nil)
    #    a = (/url=(.*)/.match(a)[1] rescue nil)
    #    raise PostError.new('unexpected new topic response from refresh') unless a

    #    a = URI.join(app_root, a)
    #    page = @agent.get(a)
    #    link = (page.search("//link[@rel='prev']").first['href'] rescue nil)
    #    raise PostError.new('unexpected new topic response from link prev') unless link

    #    # t=XXX will be our new topic id, i.e.
    #    # <link rel="prev" href="http://localhost/phpBB2/viewtopic.php?t=5&amp;view=previous" title="View previous topic"
    #    u = (URI.parse(link) rescue nil)
    #    topic = (CGI::parse(u.query)['t'][0] rescue nil)
    #    topic = topic.to_i
    #    raise PostError.new('unexpected new topic ID') unless topic > 0

    #    # save new topic id and topic name
    #    add_subject(forum, topic, subject)
    #    @forum=forum; @topic=topic; @subject=subject; @message=message
    #    true
    #  end

    #  ##
    #  # Attempt to post to the forum

    #  def post(forum = @forum, topic = @topic, message = @message)
    #    raise PostError.new("forum not set") unless forum
    #    raise PostError.new("topic not set") unless topic
    #    raise PostError.new("message not set") unless message

    #    login
    #    raise PostError.new("not logged in") unless @loggedin

    #    uri = posting_page
    #    uri.query = "mode=reply&t=#{topic}"

    #    # get the submit form
    #    begin
    #      page = @agent.get(uri)
    #    rescue StandardError => err
    #      raise PostError.new(err)
    #    end

    #    form = page.form('post') rescue nil
    #    button = form.buttons.with.name('post').first rescue nil
    #    raise PostError.new("post form not found") unless button && form

    #    # set up the form and submit it
    #    form.message = message
    #    form['disable_html'] = nil
    #    form['disable_bbcode'] = 'on'
    #    form['disable_smilies'] = 'on'
    #    begin
    #      page = @agent.submit(form, button)
    #    rescue StandardError => err
    #      raise PostError.new(err)
    #    end

    #    mes = page.search("//span[@class='gen']").last
    #    posted = mes.text =~ /Your message has been entered successfully./ rescue false
    #    if posted
    #      @forum=forum; @topic=topic; @subject=get_subject(forum,topic); @message=message
    #      return true
    #    end

    #    too_many = (mes.text =~
    #      /You cannot make another post so soon after your last; please try again in a short while./ rescue
    #      false)
    #    raise ThrottledError.new("too many posts in too short amount of time") if too_many

    #    # false otherwise, should we raise an exception instead?
    #    false
    #  end

    #  ##
    #  # Get the posting page for the application (specific to phpBB2)

    #  def posting_page
    #    URI.join(app_root, config[:posting_page])
    #  end

    #  ##
    #  # returns the login form and its button from the login page

  end
end
