require File.join(File.dirname(__FILE__), 'spec_helper')

describe "impostor's post routines" do

  describe "the no-op test impostor without implemented template methods" do

    it "should post a message" do
      impostor.post(formum=1, topic=2, message="Hello World").should == {
        :forum => 1,
        :topic => 2,
        :message => "Hello World",
        :result => true
      }
    end

    it "should have post error when forum is missing for a post" do
      post = self.post
      lambda { post.post(nil, 2, "Hello World") }.should raise_error(
        WWW::Impostor::PostError,
        "Impostor error: forum not set (StandardError)"
      )
    end

    it "should have post error when topic is missing for a post" do
      post = self.post
      lambda { post.post(1, nil, "Hello World") }.should raise_error(
        WWW::Impostor::PostError,
        "Impostor error: topic not set (StandardError)"
      )
    end

    it "should have post error when message is missing for a post" do
      post = self.post
      lambda { post.post(1, 2, nil) }.should raise_error(
        WWW::Impostor::PostError,
        "Impostor error: message not set (StandardError)"
      )
    end

  end

  describe "the base post template methods" do
  end

end
