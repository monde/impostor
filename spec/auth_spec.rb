require File.join(File.dirname(__FILE__), 'spec_helper')

describe "impostor's authorization routines" do

  describe "the no-op test impostor without implemented factory methods" do

    it "should login at the server only if not logged in" do
      auth = self.auth
      auth.should_receive(:authenticated?).once.and_return(true)
      auth.login.should be_true
    end

    it "should not login when factory methods are not implemented" do
      auth = self.auth
      lambda { auth.login }.should raise_error(
        WWW::Impostor::MissingFactoryMethodError,
        "Impostor error: fetch_login_page must be implemented (StandardError)"
      )
    end

    it "should raise not implemented error when logged_in? called" do
      auth = self.auth
      lambda { auth.logged_in?(nil) }.should raise_error(
        WWW::Impostor::MissingFactoryMethodError,
        "Impostor error: logged_in? must be implemented (StandardError)"
      )
    end

    it "should raise not implemented error when fetch_login_page called" do
      auth = self.auth
      lambda { auth.fetch_login_page }.should raise_error(
        WWW::Impostor::MissingFactoryMethodError,
        "Impostor error: fetch_login_page must be implemented (StandardError)"
      )
    end

    it "should raise not implemented error when login_form_and_button called" do
      auth = self.auth
      lambda { auth.login_form_and_button(nil) }.should raise_error(
        WWW::Impostor::MissingFactoryMethodError,
        "Impostor error: login_form_and_button must be implemented (StandardError)"
      )
    end

    it "should raise not implemented error when post_login called" do
      auth = self.auth
      lambda { auth.post_login(nil, nil) }.should raise_error(
        WWW::Impostor::MissingFactoryMethodError,
        "Impostor error: post_login must be implemented (StandardError)"
      )
    end

    it "should login via composed factory methods" do

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
  end

end
