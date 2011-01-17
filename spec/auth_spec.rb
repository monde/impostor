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
        Impostor::LoginError,
        "Impostor error: not logged in (StandardError)"
      )
    end

    it "should not raise login failure when login fails" do
      auth = self.auth
      auth.should_receive(:login).once.and_return(true)
      lambda { auth.login_with_raises }.should_not raise_error
    end

    it "should not login when template methods are not implemented" do
      config = self.config
      auth = self.auth(config)
      login_uri = URI.parse("http://example.com/login")
      config.agent.should_receive(:get).with(login_uri)

      lambda { auth.login }.should raise_error(
        Impostor::MissingTemplateMethodError,
        "Impostor error: logged_in? must be implemented (StandardError)"
      )
    end

    it "should raise not implemented error when logged_in? called" do
      auth = self.auth
      lambda { auth.logged_in?(nil) }.should raise_error(
        Impostor::MissingTemplateMethodError,
        "Impostor error: logged_in? must be implemented (StandardError)"
      )
    end

    it "should return a page from fetch_login_page" do
      config = self.config
      auth = self.auth(config)
      login_uri = URI.parse("http://example.com/login")
      config.agent.should_receive(:get).with(login_uri)

      lambda {
        auth.fetch_login_page
      }.should_not raise_error
    end

    it "should handle an error in fetch_login_page" do
      config = self.config
      auth = self.auth(config)
      login_uri = URI.parse("http://example.com/login")
      config.agent.should_receive(:get).with(login_uri).and_raise(StandardError)

      lambda {
        auth.fetch_login_page
      }.should raise_error( Impostor::LoginError )
    end

    it "should raise not implemented error when get_login_form called" do
      auth = self.auth
      lambda { auth.get_login_form(nil) }.should raise_error(
        Impostor::MissingTemplateMethodError,
        "Impostor error: get_login_form must be implemented (StandardError)"
      )
    end

    it "should raise not implemented error when set_username_and_password called" do
      auth = self.auth
      lambda { auth.set_username_and_password(nil) }.should raise_error(
        Impostor::MissingTemplateMethodError,
        "Impostor error: set_username_and_password must be implemented (StandardError)"
      )
    end

    it "should raise not implemented error when post_login called" do
      auth = self.auth
      form = mock "form"
      page = mock "page"
      form.should_receive(:submit).and_return(page)
      lambda { auth.post_login(form).should == page }.should_not raise_error
    end

    it "should login via composed template methods" do

      auth = self.auth

      login_page = mock "page"
      logged_in_page = mock "page"
      form = mock "form"

      auth.should_receive(:authenticated?).once.and_return(false)
      auth.should_receive(:fetch_login_page).once.and_return(login_page)
      auth.should_receive(:logged_in?).with(login_page).once.and_return(false)
      auth.should_receive(:get_login_form).with(login_page).once.and_return(form)
      auth.should_receive(:set_username_and_password).with(form).once

      auth.should_receive(:post_login).with(form).once.and_return(logged_in_page)
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
      auth.should_not_receive(:login_form)

      lambda {
         auth.login.should be_true
      }.should_not raise_error
    end
  end

end
