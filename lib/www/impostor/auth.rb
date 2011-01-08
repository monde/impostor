class WWW::Impostor::Auth

  attr_reader :authenticated
  alias :authenticated? :authenticated

  ##
  # Auth is initialized with the config of the impostor

  def initialize(config)
    @config = config
  end

  ##
  # login to the impostor's forum
  # login is comprised of the following template methods to allow
  # implementation for specific forum applications
  #
  # * fetch_login_page
  # * logged_in?(page)
  # * login_form_and_button(page)
  # * post_login(form, button)

  def login
    return true if self.authenticated?

    page = self.fetch_login_page
    return true if self.logged_in?(page)

    form, button = self.login_form_and_button(page)
    page = self.post_login(form, button)

    @authenticated = self.logged_in?(page)
  end

  ##
  # logot of the impostor's forum

  def logout
    return false unless self.authenticated?

    @config.save_topics
    @config.save_cookie_jar

    not ( @authenticated = false )
  end

  ##
  # given the state of the page, are we logged in to the forum?

  def logged_in?(page)
    raise WWW::Impostor::MissingTemplateMethodError.new("logged_in? must be implemented")
  end

  ##
  # get the page for logging in

  def fetch_login_page
    raise WWW::Impostor::MissingTemplateMethodError.new("fetch_login_page must be implemented")
  end

  ##
  # returns the login form and its button from the login page

  def login_form_and_button(page)
    raise WWW::Impostor::MissingTemplateMethodError.new("login_form_and_button must be implemented")
  end

  ##
  # post the login form using it's button

  def post_login(form, button)
    raise WWW::Impostor::MissingTemplateMethodError.new("post_login must be implemented")
  end

end
