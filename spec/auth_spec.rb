require File.join(File.dirname(__FILE__), 'spec_helper')

describe "impostor's authorization routines" do

  describe "the no-op test impostor auth without implemented template methods" do

    it "should logout only if not logged in" do
      auth = self.auth
      auth.should_receive(:authenticated?).once.and_return(false)
      auth.logout.should_not be_true
    end

    it "should logout" do
      config = self.config
      auth = self.auth(config)
      config.should_receive(:save_topics).once
      config.should_receive(:save_cookie_jar).once
      auth.instance_variable_set("@authenticated", true)

      auth.logout.should be_true
      auth.authenticated?.should_not be_true
    end

    it "should login at the server only if not logged in" do
      auth = self.auth
      auth.should_receive(:authenticated?).once.and_return(true)
      auth.login.should be_true
    end

    it "should raise login failure when login fails" do
      auth = self.auth
      auth.should_receive(:login).once.and_return(false)
      lambda { auth.login_with_raises }.should raise_error(
        WWW::Impostor::LoginError,
        "Impostor error: not logged in (StandardError)"
      )
    end

    it "should not raise login failure when login fails" do
      auth = self.auth
      auth.should_receive(:login).once.and_return(true)
      lambda { auth.login_with_raises }.should_not raise_error
    end

    it "should not login when template methods are not implemented" do
      auth = self.auth
      lambda { auth.login }.should raise_error(
        WWW::Impostor::MissingTemplateMethodError,
        "Impostor error: fetch_login_page must be implemented (StandardError)"
      )
    end

    it "should raise not implemented error when logged_in? called" do
      auth = self.auth
      lambda { auth.logged_in?(nil) }.should raise_error(
        WWW::Impostor::MissingTemplateMethodError,
        "Impostor error: logged_in? must be implemented (StandardError)"
      )
    end

    it "should raise not implemented error when fetch_login_page called" do
      auth = self.auth
      lambda { auth.fetch_login_page }.should raise_error(
        WWW::Impostor::MissingTemplateMethodError,
        "Impostor error: fetch_login_page must be implemented (StandardError)"
      )
    end

    it "should raise not implemented error when login_form_and_button called" do
      auth = self.auth
      lambda { auth.login_form_and_button(nil) }.should raise_error(
        WWW::Impostor::MissingTemplateMethodError,
        "Impostor error: login_form_and_button must be implemented (StandardError)"
      )
    end

    it "should raise not implemented error when post_login called" do
      auth = self.auth
      lambda { auth.post_login(nil, nil) }.should raise_error(
        WWW::Impostor::MissingTemplateMethodError,
        "Impostor error: post_login must be implemented (StandardError)"
      )
    end

    it "should login via composed template methods" do

      auth = self.auth

      login_page = mock "page"
      logged_in_page = mock "page"
      form = mock "form"
      button = mock "button"

      auth.should_receive(:authenticated?).once.and_return(false)
      auth.should_receive(:fetch_login_page).once.and_return(login_page)
      auth.should_receive(:logged_in?).with(login_page).once.and_return(false)
      auth.should_receive(:login_form_and_button).with(login_page).once.and_return([form, button])

      auth.should_receive(:post_login).with(form, button).once.and_return(logged_in_page)
      auth.should_receive(:logged_in?).with(logged_in_page).once.and_return(true)

      lambda {
        auth.login.should be_true
      }.should_not raise_error

    end

    it "should not login via composed template methods if already logged in" do
      auth = self.auth
      auth.should_receive(:authenticated?).once.and_return(true)

      auth.should_not_receive(:fetch_login_page)
      auth.should_not_receive(:logged_in?)
      auth.should_not_receive(:login_form_and_button)

      lambda {
         auth.login.should be_true
      }.should_not raise_error
    end
  end

end
