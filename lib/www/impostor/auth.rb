class WWW::Impostor::Auth

  attr_reader :logged_in

  def initialize(config)
    @config = config
  end

  def login
    return true if self.logged_in?

    page = self.fetch_login_page
    return true if self.logged_in?(page)

    form, button = self.login_form_and_button(page)
    page = self.post_login(form, button)

    self.logged_in?(page)
  end

  def logged_in?
    raise WWW::Impostor::MissingFactoryMethodError.new("logged_in? must be implemented")
  end

  def fetch_login_page
    raise WWW::Impostor::MissingFactoryMethodError.new("fetch_login_page must be implemented")
  end

  def post_login(form, button)
    raise WWW::Impostor::MissingFactoryMethodError.new("post_login must be implemented")
  end

end
