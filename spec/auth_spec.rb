require File.join(File.dirname(__FILE__), 'spec_helper')

describe "impostor's authorization routines" do

  describe "the no-op test impostor with out implemented factory methods" do

    it "should login at the server only if not logged in" do
      auth = self.auth
      auth.should_receive(:logged_in?).once.and_return(true)
      auth.login.should be_true
    end

    it "should raise not implemented error when logged_in? called" do
      auth = self.auth
      lambda { auth.logged_in? }.should raise_error(
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

    it "should raise not implemented error when post_login called" do
      auth = self.auth
      lambda { auth.post_login(nil, nil) }.should raise_error(
        WWW::Impostor::MissingFactoryMethodError,
        "Impostor error: post_login must be implemented (StandardError)"
      )
    end

  end

end
