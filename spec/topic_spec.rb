require File.join(File.dirname(__FILE__), 'spec_helper')

describe "impostor's topic routines" do

  describe "the no-op test impostor topic without implemented template methods" do

    it "should create new_topic via composed template methods" do

      config = self.config
      auth = self.auth
      topic = self.topic(config, auth)

      new_topic_uri = mock "new topic uri"
      new_topic_page = mock "new topic page"
      new_topic_form = mock "new topic form"
      new_topic_result = mock "new topic result page"

      auth.should_receive(:login_with_raises).once.and_return(true)
      topic.should_receive(:get_new_topic_uri).with(1, "OMG!", "Hello World").and_return(new_topic_uri)

      topic.should_receive(:get_new_topic_page).with(new_topic_uri).and_return(new_topic_page)
      topic.should_receive(:get_new_topic_form).with(new_topic_page).and_return(new_topic_form)
      topic.should_receive(:set_subject_and_message).with(new_topic_form, "OMG!", "Hello World")
      topic.should_receive(:post_new_topic).with(new_topic_form).and_return(new_topic_result)
      topic.should_receive(:validate_new_topic_result).with(new_topic_result)
      topic.should_receive(:get_topic_from_result).with(new_topic_result).and_return(2)
      config.should_receive(:add_subject).with(1, 2, "OMG!")

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

      config = self.config
      auth = self.auth
      topic = self.topic(config, auth)

      auth.should_receive(:login_with_raises).and_raise(Impostor::LoginError)

      lambda {
        topic.new_topic(formum=1, subject="OMG!", message="Hello World")
      }.should raise_error( Impostor::LoginError )
    end

  end

  describe "the base topic template methods" do

    it "should have topic error when forum is missing in #validate_topic_input" do
      lambda { topic.validate_topic_input(nil, subject="OMG!", message="Hello World") }.should raise_error(
        Impostor::TopicError,
        "Impostor error: forum not set (StandardError)"
      )
    end

    it "should have topic error when subject is missing in #validate_topic_input" do
      lambda { topic.validate_topic_input(forum=1, nil, message="Hello World") }.should raise_error(
        Impostor::TopicError,
        "Impostor error: subject not set (StandardError)"
      )
    end

    it "should have topic error when message is missing in #validate_topic_input" do
      lambda { topic.validate_topic_input(forum=1, subject="OMG!", nil) }.should raise_error(
        Impostor::TopicError,
        "Impostor error: message not set (StandardError)"
      )
    end

    it "should raise not implemented error when get_new_topic_uri called" do
      lambda { topic.get_new_topic_uri(nil, nil, nil) }.should raise_error(
        Impostor::MissingTemplateMethodError,
        "Impostor error: get_new_topic_uri must be implemented (StandardError)"
      )
    end

    it "should raise not implemented error when get_new_topic_page called" do
      topic = self.topic
      uri = mock "uri"
      topic.config.agent.should_receive(:get).with(uri)
      lambda {
        topic.get_new_topic_page(uri)
      }.should_not raise_error
    end

    it "should raise not implemented error when get_new_topic_form called" do
      lambda { topic.get_new_topic_form(nil) }.should raise_error(
        Impostor::MissingTemplateMethodError,
        "Impostor error: get_new_topic_form must be implemented (StandardError)"
      )
    end

    it "should raise not implemented error when set_subject_and_message called" do
      lambda { topic.set_subject_and_message(nil, nil, nil) }.should raise_error(
        Impostor::MissingTemplateMethodError,
        "Impostor error: set_subject_and_message must be implemented (StandardError)"
      )
    end

    it "should raise not implemented error when post_new_topic called" do
      lambda { topic.post_new_topic(nil) }.should raise_error(
        Impostor::MissingTemplateMethodError,
        "Impostor error: post_new_topic must be implemented (StandardError)"
      )
    end

    it "should raise not implemented error when validate_new_topic_result called" do
      lambda { topic.validate_new_topic_result(nil) }.should raise_error(
        Impostor::MissingTemplateMethodError,
        "Impostor error: validate_new_topic_result must be implemented (StandardError)"
      )
    end

    it "should raise not implemented error when get_topic_from_result called" do
      lambda { topic.get_topic_from_result(nil) }.should raise_error(
        Impostor::MissingTemplateMethodError,
        "Impostor error: get_topic_from_result must be implemented (StandardError)"
      )
    end

  end

end
