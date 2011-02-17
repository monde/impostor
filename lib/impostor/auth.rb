class Impostor::Auth

  attr_reader :config
  attr_reader :authenticated
  alias :authenticated? :authenticated

  ##
  # Auth is initialized with the config of the impostor

  def initialize(config)
    @config = config
    self.extend eval("Impostor::#{config.type.to_s.capitalize}::Auth")
  end

  ##
  # Login to the impostor's forum.  #login is comprised of the following
  # template methods to allow implementation for specific forum applications:
  #
  # * fetch_login_page
  # * logged_in?(page)
  # * get_login_form(page)
  # * set_username_and_password(form)
  # * post_login(form)

  def login
    return true if self.authenticated?

    page = self.fetch_login_page
    return true if self.logged_in?(page)

    form = self.get_login_form(page)
    self.set_username_and_password(form)
    page = self.post_login(form)

    @authenticated = self.logged_in?(page)
  end

  def login_with_raises
    return true if self.login

    raise Impostor::LoginError.new("not logged in")
  end

  ##
  # logot of the impostor's forum

  def logout
    return false unless self.authenticated?

    self.config.save_topics
    self.config.save_cookie_jar

    @authenticated = false

    not self.authenticated?
  end

  ##
  # given the state of the page, are we logged in to the forum?

  def logged_in?(page)
    raise Impostor::MissingTemplateMethodError.new("logged_in? must be implemented")
  end

  ##
  # get the page for logging in

  def fetch_login_page
    begin
      self.config.agent.get(self.config.login_page)
    rescue StandardError => err
      raise Impostor::LoginError.new(err)
    end
  end

  ##
  # returns the login form from the login page

  def get_login_form(page)
    raise Impostor::MissingTemplateMethodError.new("get_login_form must be implemented")
  end

  ##
  # Sets the user name and pass word on the loing form.

  def set_username_and_password(form)
    raise Impostor::MissingTemplateMethodError.new("set_username_and_password must be implemented")
  end

  ##
  # does the work of posting the login form

  def post_login(form)
    begin
      config.sleep_before_post
      page = form.submit
    rescue StandardError => err
      raise Impostor::LoginError.new(err)
    end
  end


end
