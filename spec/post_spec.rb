require File.join(File.dirname(__FILE__), 'spec_helper')

describe "impostor's post routines" do

  describe "the no-op test impostor post without implemented template methods" do

    it "should post via composed template methods" do

      config = self.config
      auth = self.auth
      post = self.post(config, auth)

      auth.should_receive(:login_with_raises).once.and_return(true)

      lambda {
        post.post(formum=1, topic=2, message="Hello World").should == {
          :forum => 1,
          :topic => 2,
          :message => "Hello World",
          :result => true
        }
      }.should_not raise_error

    end

    it "should have logged in error when posting and not logged in" do

      config = self.config
      auth = self.auth
      post = self.post(config, auth)

      auth.should_receive(:login_with_raises).and_raise(WWW::Impostor::LoginError)

      lambda {
        post.post(formum=1, topic=2, message="Hello World")
      }.should raise_error( WWW::Impostor::LoginError )
    end

  end

  describe "the base post template methods" do

    it "should have post error when forum is missing in #validate_post_input" do
      post = self.post
      lambda { post.validate_post_input(nil, 2, "Hello World") }.should raise_error(
        WWW::Impostor::PostError,
        "Impostor error: forum not set (StandardError)"
      )
    end

    it "should have post error when topic is missing in #validate_post_input" do
      post = self.post
      lambda { post.validate_post_input(1, nil, "Hello World") }.should raise_error(
        WWW::Impostor::PostError,
        "Impostor error: topic not set (StandardError)"
      )
    end

    it "should have post error when message is missing in #validate_post_input" do
      post = self.post
      lambda { post.validate_post_input(1, 2, nil) }.should raise_error(
        WWW::Impostor::PostError,
        "Impostor error: message not set (StandardError)"
      )
    end

  end

end
