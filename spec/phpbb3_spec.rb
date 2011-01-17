require File.join(File.dirname(__FILE__), 'spec_helper')

describe "a phpbb3 impostor" do

  describe "authentication routines" do

    it "should be logged_in? when phpbb3 displays the user name" do
      config = self.config(sample_phpbb3_config_params)
      auth = self.auth(config)
      page = load_fixture_page("phpbb3-logged-in.html", config.app_root, 200, config.agent)

      lambda {
        auth.logged_in?(page).should be_true
      }.should_not raise_error
    end

    it "should not be logged_in? when phpbb3 does not display the user name" do
      config = self.config(sample_phpbb3_config_params)
      auth = self.auth(config)
      page = load_fixture_page("phpbb3-not-logged-in.html", config.app_root, 200, config.agent)

      lambda {
        auth.logged_in?(page).should_not be_true
      }.should_not raise_error
    end

    it "should return a page from fetch_login_page" do
      config = self.config(sample_phpbb3_config_params)
      auth = self.auth(config)
      login_uri = URI.parse("http://example.com/forum/ucp.php?mode=login")
      config.agent.should_receive(:get).with(login_uri)

      lambda {
        auth.fetch_login_page
      }.should_not raise_error
    end

    it "should handle an error in fetch_login_page" do
      config = self.config(sample_phpbb3_config_params)
      auth = self.auth(config)
      login_uri = URI.parse("http://example.com/forum/ucp.php?mode=login")
      config.agent.should_receive(:get).with(login_uri).and_raise(StandardError)

      lambda {
        auth.fetch_login_page
      }.should raise_error( Impostor::LoginError )
    end

    it "should return a login form from get_login_form" do
      config = self.config(sample_phpbb3_config_params)
      auth = self.auth(config)
      page = load_fixture_page("phpbb3-login.html", config.login_page, 200, config.agent)

      lambda {
        auth.get_login_form(page).action.should match(/\/ucp\.php\?mode=login/)
      }.should_not raise_error
    end

    it "should raise login error when get_login_form receives a bad page" do
      config = self.config(sample_phpbb3_config_params)
      auth = self.auth(config)
      page = load_fixture_page("junk.html", config.login_page, 200, config.agent)

      lambda {
        auth.get_login_form(page)
      }.should raise_error( Impostor::LoginError )
    end

    it "should setup login form in set_username_and_password" do
      config = self.config(sample_phpbb3_config_params)
      auth = self.auth(config)
      form = mock "login form"
      form.should_receive(:[]=).with("username", "tester")
      form.should_receive(:[]=).with("password", "pass")
      form.should_receive(:[]=).with("autologin", "on")
      lambda {
        auth.set_username_and_password(form).should == form
      }.should_not raise_error
    end

    #it "should return a logged in page when posting the login" do
    #  config = self.config(sample_phpbb3_config_params)
    #  auth = self.auth(config)
    #  login_page = load_fixture_page("wwf80-login.html", config.login_page, 200, config.agent)
    #  form = login_page.form('frmLogin')
    #  logged_in_page = load_fixture_page("wwf80-logged-in.html", config.app_root, 200, config.agent)
    #  config.agent.should_receive(:submit).with(instance_of(Mechanize::Form), nil, {}).and_return(logged_in_page)
    #  lambda {
    #    auth.post_login(form).should == logged_in_page
    #  }.should_not raise_error
    #end

    #it "should raise a login error when posting has an underlying exception" do
    #  config = self.config(sample_phpbb3_config_params)
    #  auth = self.auth(config)
    #  login_page = load_fixture_page("wwf80-login.html", config.login_page, 200, config.agent)
    #  form = login_page.form('frmLogin')
    #  logged_in_page = load_fixture_page("wwf80-logged-in.html", config.app_root, 200, config.agent)
    #  config.agent.should_receive(:submit).with(instance_of(Mechanize::Form), nil, {}).and_raise(StandardError)
    #  lambda {
    #    auth.post_login(form)
    #  }.should raise_error( Impostor::LoginError )
    #end

    #it "should login" do
    #  config = self.config(sample_phpbb3_config_params)
    #  auth = self.auth(config)
    #  login_page = load_fixture_page("wwf80-login.html", config.login_page, 200, config.agent)
    #  logged_in_page = load_fixture_page("wwf80-logged-in.html", config.app_root, 200, config.agent)
    #  login_uri = URI.parse("http://example.com/forum/login_user.asp")

    #  config.agent.should_receive(:get).with(login_uri).and_return(login_page)
    #  config.agent.should_receive(:submit).with(instance_of(Mechanize::Form), nil, {}).and_return(logged_in_page)

    #  lambda {
    #    auth.login.should be_true
    #  }.should_not raise_error
    #end
  end

end

