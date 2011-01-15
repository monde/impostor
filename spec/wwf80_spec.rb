require File.join(File.dirname(__FILE__), 'spec_helper')

describe "a Web Wiz Forum 8.0 impostor" do

  describe "authentication routines" do

    it "should be logged_in? when wwf 8.0 displays the user name" do
      config = self.config(sample_wwf80_config_params)
      auth = self.auth(config)
      page = load_fixture_page("wwf80-logged-in.html", config.app_root, 200, config.agent)

      lambda {
        auth.logged_in?(page).should be_true
      }.should_not raise_error
    end

    it "should not be logged_in? when wwf 8.0 does not display the user name" do
      config = self.config(sample_wwf80_config_params)
      auth = self.auth(config)
      page = load_fixture_page("wwf80-not-logged-in.html", config.app_root, 200, config.agent)

      lambda {
        auth.logged_in?(page).should_not be_true
      }.should_not raise_error
    end

    it "should return a page from fetch_login_page" do
      config = self.config(sample_wwf80_config_params)
      auth = self.auth(config)
      login_uri = URI.parse("http://example.com/forum/login_user.asp")
      config.agent.should_receive(:get).with(login_uri)

      lambda {
        auth.fetch_login_page
      }.should_not raise_error
    end

    it "should handle an error in fetch_login_page" do
      config = self.config(sample_wwf80_config_params)
      auth = self.auth(config)
      login_uri = URI.parse("http://example.com/forum/login_user.asp")
      config.agent.should_receive(:get).with(login_uri).and_raise(StandardError)

      lambda {
        auth.fetch_login_page
      }.should raise_error( WWW::Impostor::LoginError )
    end

    it "should return a login form from get_login_form"

    it "should raise login error when get_login_form receives a bad page"

    it "should return a logged in page when posting the login"

    it "should raise a login error when posting has an underlying exception"

    it "should login" do
      config = self.config(sample_wwf80_config_params)
      auth = self.auth(config)
      login_page = load_fixture_page("wwf80-login.html", config.login_page, 200, config.agent)
      logged_in_page = load_fixture_page("wwf80-logged-in.html", config.app_root, 200, config.agent)
      login_uri = URI.parse("http://example.com/forum/login_user.asp")

      config.agent.should_receive(:get).with(login_uri).and_return(login_page)
      config.agent.should_receive(:submit).with(instance_of(Mechanize::Form), nil, {}).and_return(logged_in_page)

      lambda {
        auth.login.should be_true
      }.should_not raise_error
    end
  end

end

