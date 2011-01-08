class WWW::Impostor::Auth

  attr_reader :authenticated
  alias :authenticated? :authenticated

  def initialize(config)
    @config = config
  end

  def login
    return true if self.authenticated?

    page = self.fetch_login_page
    return true if self.logged_in?(page)

    form, button = self.login_form_and_button(page)
    page = self.post_login(form, button)

    @authenticated = self.logged_in?(page)
  end

  def logout
    return false unless self.authenticated?

    @config.save_topics
    @config.save_cookie_jar

    not ( @authenticated = false )
  end

  def logged_in?(page)
    raise WWW::Impostor::MissingFactoryMethodError.new("logged_in? must be implemented")
  end

  def fetch_login_page
    raise WWW::Impostor::MissingFactoryMethodError.new("fetch_login_page must be implemented")
  end

  ##
  # returns the login form and its button from the login page

  def login_form_and_button(page)
    raise WWW::Impostor::MissingFactoryMethodError.new("login_form_and_button must be implemented")
  end

  def post_login(form, button)
    raise WWW::Impostor::MissingFactoryMethodError.new("post_login must be implemented")
  end

end
