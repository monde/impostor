require File.join(File.dirname(__FILE__), 'spec_helper')

describe "a Web Wiz Forum 7.9 impostor" do

  describe "authentication routines" do

    it "should logout only if not logged in" do
      auth = wwf79_auth
      auth.should_receive(:authenticated?).once.and_return(false)
      auth.logout.should_not be_true
    end

    it "should logout" do
      auth = wwf79_auth
      auth.config.should_receive(:save_topics).once
      auth.config.should_receive(:save_cookie_jar).once
      auth.instance_variable_set("@authenticated", true)

      auth.logout.should be_true
      auth.authenticated?.should_not be_true
    end

    it "should be logged_in? when wwf 7.9 displays the user name" do
      auth = wwf79_auth
      page = load_fixture_page("wwf79-logged-in.html", auth.config.app_root, 200, auth.config.agent)

      lambda {
        auth.logged_in?(page).should be_true
      }.should_not raise_error
    end

    it "should not be logged_in? when wwf 7.9 does not display the user name" do
      auth = wwf79_auth
      page = load_fixture_page("wwf79-not-logged-in.html", auth.config.app_root, 200, auth.config.agent)

      lambda {
        auth.logged_in?(page).should_not be_true
      }.should_not raise_error
    end

    it "should return a page from fetch_login_page" do
      auth = wwf79_auth
      login_uri = URI.parse("http://example.com/forum/login_user.asp")
      auth.config.agent.should_receive(:get).with(login_uri)

      lambda {
        auth.fetch_login_page
      }.should_not raise_error
    end

    it "should handle an error in fetch_login_page" do
      auth = wwf79_auth
      login_uri = URI.parse("http://example.com/forum/login_user.asp")
      auth.config.agent.should_receive(:get).with(login_uri).and_raise(StandardError)

      lambda {
        auth.fetch_login_page
      }.should raise_error( Impostor::LoginError )
    end

    it "should return a login form from get_login_form" do
      auth = wwf79_auth
      page = load_fixture_page("wwf79-login.html", auth.config.login_page, 200, auth.config.agent)

      lambda {
        auth.get_login_form(page).name.should == 'frmLogin'
      }.should_not raise_error
    end

    it "should raise login error when get_login_form receives a bad page" do
      auth = wwf79_auth
      page = load_fixture_page("junk.html", auth.config.login_page, 200, auth.config.agent)

      lambda {
        auth.get_login_form(page)
      }.should raise_error( Impostor::LoginError )
    end

    it "should setup login form in set_username_and_password" do
      auth = wwf79_auth
      form = mock "login form"
      button = mock "submit button"
      Mechanize::Form::Button.should_receive(:new).and_return(button)
      form.should_receive(:[]=).with("name", "tester")
      form.should_receive(:[]=).with("password", "pass")
      form.should_receive(:add_button_to_query).with(button)
      lambda {
        auth.set_username_and_password(form).should == form
      }.should_not raise_error
    end

    it "should return a logged in page when posting the login" do
      auth = wwf79_auth
      login_page = load_fixture_page("wwf79-login.html", auth.config.login_page, 200, auth.config.agent)
      form = auth.get_login_form(login_page)
      logged_in_page = load_fixture_page("wwf79-logged-in.html", auth.config.app_root, 200, auth.config.agent)
      auth.config.agent.should_receive(:submit).with(instance_of(Mechanize::Form), nil, {}).and_return(logged_in_page)
      lambda {
        auth.post_login(form).should == logged_in_page
      }.should_not raise_error
    end

    it "should raise a login error when posting has an underlying exception" do
      auth = wwf79_auth
      login_page = load_fixture_page("wwf79-login.html", auth.config.login_page, 200, auth.config.agent)
      form = login_page.form('frmLogin')
      logged_in_page = load_fixture_page("wwf79-logged-in.html", auth.config.app_root, 200, auth.config.agent)
      auth.config.agent.should_receive(:submit).with(instance_of(Mechanize::Form), nil, {}).and_raise(StandardError)
      lambda {
        auth.post_login(form)
      }.should raise_error( Impostor::LoginError )
    end

    it "should login" do
      auth = wwf79_auth
      login_page = load_fixture_page("wwf79-login.html", auth.config.login_page, 200, auth.config.agent)
      logged_in_page = load_fixture_page("wwf79-logged-in.html", auth.config.app_root, 200, auth.config.agent)
      login_uri = URI.parse("http://example.com/forum/login_user.asp")

      auth.config.agent.should_receive(:get).with(login_uri).and_return(login_page)
      auth.config.agent.should_receive(:submit).with(instance_of(Mechanize::Form), nil, {}).and_return(logged_in_page)

      lambda {
        auth.login.should be_true
      }.should_not raise_error
    end
  end

end

