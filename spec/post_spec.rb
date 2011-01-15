require File.join(File.dirname(__FILE__), 'spec_helper')

describe "impostor's post routines" do

  describe "the no-op test impostor post without implemented template methods" do

    it "should post via composed template methods" do

      config = self.config
      auth = self.auth
      post = self.post(config, auth)

      reply_uri = mock "reply_uri"
      reply_page = mock "reply page"
      reply_form = mock "reply form"
      result_page = mock "result page"

      auth.should_receive(:login_with_raises).once.and_return(true)
      post.should_receive(:get_reply_uri).with(1,2,"Hello World").once.and_return(reply_uri)
      post.should_receive(:get_reply_page).with(reply_uri).once.and_return(reply_page)
      post.should_receive(:get_post_form).with(reply_page).once.and_return(reply_form)
      post.should_receive(:set_message).with(reply_form, "Hello World").once
      post.should_receive(:post_message).with(reply_form).once.and_return(result_page)
      post.should_receive(:validate_post_result).with(result_page).once

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

      auth.should_receive(:login_with_raises).and_raise(Impostor::LoginError)

      lambda {
        post.post(formum=1, topic=2, message="Hello World")
      }.should raise_error( Impostor::LoginError )
    end

  end

  describe "the base post template methods" do

    it "should have post error when forum is missing in #validate_post_input" do
      lambda { post.validate_post_input(nil, 2, "Hello World") }.should raise_error(
        Impostor::PostError,
        "Impostor error: forum not set (StandardError)"
      )
    end

    it "should have post error when topic is missing in #validate_post_input" do
      lambda { post.validate_post_input(1, nil, "Hello World") }.should raise_error(
        Impostor::PostError,
        "Impostor error: topic not set (StandardError)"
      )
    end

    it "should have post error when message is missing in #validate_post_input" do
      lambda { post.validate_post_input(1, 2, nil) }.should raise_error(
        Impostor::PostError,
        "Impostor error: message not set (StandardError)"
      )
    end

    it "should raise not implemented error when get_reply_uri called" do
      lambda { post.get_reply_uri(nil, nil, nil) }.should raise_error(
        Impostor::MissingTemplateMethodError,
        "Impostor error: get_reply_uri must be implemented (StandardError)"
      )
    end

    it "should raise not implemented error when get_reply_page called" do
      lambda { post.get_reply_page(nil) }.should raise_error(
        Impostor::MissingTemplateMethodError,
        "Impostor error: get_reply_page must be implemented (StandardError)"
      )
    end

    it "should raise not implemented error when get_post_form called" do
      lambda { post.get_post_form(nil) }.should raise_error(
        Impostor::MissingTemplateMethodError,
        "Impostor error: get_post_form must be implemented (StandardError)"
      )
    end

    it "should raise not implemented error when set_message called" do
      lambda { post.set_message(nil, nil) }.should raise_error(
        Impostor::MissingTemplateMethodError,
        "Impostor error: set_message must be implemented (StandardError)"
      )
    end

    it "should raise not implemented error when post_message called" do
      lambda { post.post_message(nil) }.should raise_error(
        Impostor::MissingTemplateMethodError,
        "Impostor error: post_message must be implemented (StandardError)"
      )
    end

    it "should raise not implemented error when validate_post_result called" do
      lambda { post.validate_post_result(nil) }.should raise_error(
        Impostor::MissingTemplateMethodError,
        "Impostor error: validate_post_result must be implemented (StandardError)"
      )
    end

  end

end
