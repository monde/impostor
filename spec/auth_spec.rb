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

  end

end
