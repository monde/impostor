require File.join(File.dirname(__FILE__), 'spec_helper')

describe "impostor's topic routines" do

  describe "the no-op test impostor topic without implemented template methods" do

    it "should create new_topic via composed template methods" do

      lambda {
        topic.new_topic(formum=1, subject="OMG!", message="Hello World").should == {
          :forum => 1,
          :topic => 2,
          :subject => "OMG!",
          :message => "Hello World",
          :result => true
        }
      }.should_not raise_error

    end

    it "should have logged in error when creating a new topic and not logged in" do

      lambda {
        topic.new_topic(formum=1, subject="OMG!", message="Hello World")
      }.should raise_error( WWW::Impostor::LoginError )
    end

  end

  describe "the base topic template methods" do

    it "should have topic error when forum is missing in #validate_topic_input" do
      lambda { topic.validate_topic_input(nil, subject="OMG!", message="Hello World") }.should raise_error(
        WWW::Impostor::TopicError,
        "Impostor error: forum not set (StandardError)"
      )
    end

    it "should have topic error when subject is missing in #validate_topic_input" do
      lambda { topic.validate_topic_input(forum=1, nil, message="Hello World") }.should raise_error(
        WWW::Impostor::TopicError,
        "Impostor error: subject not set (StandardError)"
      )
    end

    it "should have topic error when message is missing in #validate_topic_input" do
      lambda { topic.validate_topic_input(forum=1, subject="OMG!", nil) }.should raise_error(
        WWW::Impostor::TopicError,
        "Impostor error: message not set (StandardError)"
      )
    end

  end

end
