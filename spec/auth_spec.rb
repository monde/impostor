require File.join(File.dirname(__FILE__), 'spec_helper')

describe "impostor's authorization routines" do

  it "should login at the server only if not logged in" do
    auth = self.auth
    auth.should_receive(:logged_in?).once.and_return(true)
    auth.login.should be_true
  end

end
