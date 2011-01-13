class WWW::Impostor::Auth

  attr_reader :authenticated
  alias :authenticated? :authenticated

  ##
  # Auth is initialized with the config of the impostor

  def initialize(config)
    @config = config
  end

  ##
  # Login to the impostor's forum.  Optional raises parameter will flag to
  # raise an login error if login fails and raises is true.
  # #login is comprised of the following template methods to allow
  # implementation for specific forum applications
  #
  # * fetch_login_page
  # * logged_in?(page)
  # * get_login_form(page)
  # * post_login(form)

  def login(raises=false)
    return true if self.authenticated?

    page = self.fetch_login_page
    return true if self.logged_in?(page)

    form = self.get_login_form(page)
    page = self.post_login(form)

    @authenticated = self.logged_in?(page)
  end

  def login_with_raises
    return true if self.login

    raise WWW::Impostor::LoginError.new("not logged in")
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
  # returns the login form from the login page

  def get_login_form(page)
    raise WWW::Impostor::MissingTemplateMethodError.new("get_login_form must be implemented")
  end

  ##
  # post the login form using it's button

  def post_login(form)
    raise WWW::Impostor::MissingTemplateMethodError.new("post_login must be implemented")
  end

end
