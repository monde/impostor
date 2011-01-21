require File.join(File.dirname(__FILE__), 'spec_helper')

describe "a Web Wiz Forum 8.0 impostor" do

  describe "authentication routines" do

    it "should logout only if not logged in" do
      auth = wwf80_auth
      auth.should_receive(:authenticated?).once.and_return(false)
      auth.logout.should_not be_true
    end

    it "should logout" do
      auth = wwf80_auth
      auth.config.should_receive(:save_topics).once
      auth.config.should_receive(:save_cookie_jar).once
      auth.instance_variable_set("@authenticated", true)

      auth.logout.should be_true
      auth.authenticated?.should_not be_true
    end

    it "should be logged_in? when wwf 8.0 displays the user name" do
      auth = wwf80_auth
      page = load_fixture_page("wwf80-logged-in.html", auth.config.app_root, 200, auth.config.agent)

      lambda {
        auth.logged_in?(page).should be_true
      }.should_not raise_error
    end

    it "should not be logged_in? when wwf 8.0 does not display the user name" do
      auth = wwf80_auth
      page = load_fixture_page("wwf80-not-logged-in.html", auth.config.app_root, 200, auth.config.agent)

      lambda {
        auth.logged_in?(page).should_not be_true
      }.should_not raise_error
    end

    it "should return a page from fetch_login_page" do
      auth = wwf80_auth
      login_uri = URI.parse("http://example.com/forum/login_user.asp")
      auth.config.agent.should_receive(:get).with(login_uri)

      lambda {
        auth.fetch_login_page
      }.should_not raise_error
    end

    it "should handle an error in fetch_login_page" do
      auth = wwf80_auth
      login_uri = URI.parse("http://example.com/forum/login_user.asp")
      auth.config.agent.should_receive(:get).with(login_uri).and_raise(StandardError)

      lambda {
        auth.fetch_login_page
      }.should raise_error( Impostor::LoginError )
    end

    it "should return a login form from get_login_form" do
      auth = wwf80_auth
      page = load_fixture_page("wwf80-login.html", auth.config.login_page, 200, auth.config.agent)

      lambda {
        auth.get_login_form(page).name.should == 'frmLogin'
      }.should_not raise_error
    end

    it "should raise login error when get_login_form receives a bad page" do
      auth = wwf80_auth
      page = load_fixture_page("junk.html", auth.config.login_page, 200, auth.config.agent)

      lambda {
        auth.get_login_form(page)
      }.should raise_error( Impostor::LoginError )
    end

    it "should setup login form in set_username_and_password" do
      auth = wwf80_auth
      form = mock "login form"
      form.should_receive(:[]=).with("name", "tester")
      form.should_receive(:[]=).with("password", "pass")
      lambda {
        auth.set_username_and_password(form).should == form
      }.should_not raise_error
    end

    it "should return a logged in page when posting the login" do
      auth = wwf80_auth
      login_page = load_fixture_page("wwf80-login.html", auth.config.login_page, 200, auth.config.agent)
      form = auth.get_login_form(login_page)
      logged_in_page = load_fixture_page("wwf80-logged-in.html", auth.config.app_root, 200, auth.config.agent)
      auth.config.agent.should_receive(:submit).with(instance_of(Mechanize::Form), nil, {}).and_return(logged_in_page)
      lambda {
        auth.post_login(form).should == logged_in_page
      }.should_not raise_error
    end

    it "should raise a login error when posting has an underlying exception" do
      auth = wwf80_auth
      login_page = load_fixture_page("wwf80-login.html", auth.config.login_page, 200, auth.config.agent)
      form = login_page.form('frmLogin')
      logged_in_page = load_fixture_page("wwf80-logged-in.html", auth.config.app_root, 200, auth.config.agent)
      auth.config.agent.should_receive(:submit).with(instance_of(Mechanize::Form), nil, {}).and_raise(StandardError)
      lambda {
        auth.post_login(form)
      }.should raise_error( Impostor::LoginError )
    end

    it "should login" do
      auth = wwf80_auth
      login_page = load_fixture_page("wwf80-login.html", auth.config.login_page, 200, auth.config.agent)
      logged_in_page = load_fixture_page("wwf80-logged-in.html", auth.config.app_root, 200, auth.config.agent)
      login_uri = URI.parse("http://example.com/forum/login_user.asp")

      auth.config.agent.should_receive(:get).with(login_uri).and_return(login_page)
      auth.config.agent.should_receive(:submit).with(instance_of(Mechanize::Form), nil, {}).and_return(logged_in_page)

      lambda {
        auth.login.should be_true
      }.should_not raise_error
    end

  end

  describe "posting routines" do

    it "should post a message in the topic of a forum" do
      post = wwf80_post
      post.auth.should_receive(:login_with_raises)
      reply_uri = URI.parse("http://example.com/forum/new_reply_form.asp?TID=2")
      reply_page = load_fixture_page("wwf80-new_reply_form.html", reply_uri, 200, post.config.agent)
      post.config.agent.should_receive(:get).with(reply_uri).and_return(reply_page)
      good_post_page = load_fixture_page("wwf80-post-reply-good-response.html", post.config.app_root, 200, post.config.agent)
      post.config.agent.should_receive(:submit).with(instance_of(Mechanize::Form), nil, {}).and_return(good_post_page)

      lambda {
        post.post(formum=1, topic=2, message="Hello World").should == {
          :forum => 1,
          :topic => 2,
          :message => "Hello World",
          :result => true
        }
      }.should_not raise_error
    end

    it "should get a reply uri from get_reply_uri(forum, topic)" do
      post = wwf80_post
      reply_uri = URI.parse("http://example.com/forum/new_reply_form.asp?TID=2")
      lambda {
        post.get_reply_uri(1,2).should == reply_uri
      }.should_not raise_error
    end

    it "should get_reply_page(uri)" do
      post = wwf80_post
      reply_uri = URI.parse("http://example.com/forum/new_reply_form.asp?TID=2")
      reply_page = load_fixture_page("wwf80-new_reply_form.html", reply_uri, 200, post.config.agent)

      post.config.agent.should_receive(:get).with(reply_uri).and_return(reply_page)
      lambda {
        post.get_reply_page(reply_uri).should == reply_page
      }.should_not raise_error
    end

    it "should return reply from with get_post_form(page)" do
      post = wwf80_post
      reply_uri = URI.parse("http://example.com/forum/new_reply_form.asp?TID=2")
      reply_page = load_fixture_page("wwf80-new_reply_form.html", reply_uri, 200, post.config.agent)
      lambda {
        post.get_post_form(reply_page).name.should == 'frmMessageForm'
      }.should_not raise_error
    end

    it "should raise error when page to get_post_form(page) receives a bad page" do
      post = wwf80_post
      reply_uri = URI.parse("http://example.com/forum/new_reply_form.asp?TID=2")

      page = load_fixture_page("junk.html", reply_uri, 200, post.config.agent)

      lambda {
        post.get_post_form(page)
      }.should raise_error( Impostor::PostError )
    end

    it "should set_message(form, message)" do
      post = wwf80_post
      reply_uri = URI.parse("http://example.com/forum/new_reply_form.asp?TID=2")
      reply_page = load_fixture_page("wwf80-new_reply_form.html", reply_uri, 200, post.config.agent)
      form = post.get_post_form(reply_page)
      form.should_receive(:message=, "Hello World")
      lambda {
        post.set_message(form, "Hello World")
      }.should_not raise_error
    end

    it "should return response page from post_message(form)" do
      post = wwf80_post
      form = mock "post form"
      reply_page = mock "reply page"
      form.should_receive(:submit).and_return reply_page
      lambda {
        post.post_message(form).should == reply_page
      }.should_not raise_error
    end

    it "should raise post error when post_form fails" do
      post = wwf80_post
      form = mock "post form"
      form.should_receive(:submit).and_raise( Impostor::PostError )
      lambda {
        post.post_message(form)
      }.should raise_error( Impostor::PostError )
    end

    it "should not raise post error on valid reply validate_post_result(page)" do
      post = wwf80_post
      page = load_fixture_page("wwf80-post-reply-good-response.html", post.config.app_root, 200, post.config.agent)
      lambda {
        post.validate_post_result(page).should be_true
      }.should_not raise_error
    end

    it "should raise post error on invalid reply validate_post_result(page)" do
      post = wwf80_post
      page = load_fixture_page("wwf80-general-posting-error.html", post.config.app_root, 200, post.config.agent)
      lambda {
        post.validate_post_result(page)
      }.should raise_error( Impostor::PostError )
    end

  end

  describe "wwf 80 topic methods" do

    it "should return new topic uri when get_new_topic_uri called" do
      topic = wwf80_topic
      new_topic_uri = URI.parse("http://example.com/forum/new_topic_form.asp?FID=1")
      lambda {
        topic.get_new_topic_uri(1, "OMG!", "Hello World").should == new_topic_uri
      }.should_not raise_error
    end

    it "should return new topic page when get_new_topic_page called" do
      topic = wwf80_topic
      new_topic_uri = URI.parse("http://example.com/forum/new_topic_form.asp?FID=1")

      new_topic_page = load_fixture_page("wwf80-get-new_topic-form-good-response.html", new_topic_uri, 200, post.config.agent)

      topic.config.agent.should_receive(:get).with(new_topic_uri).and_return(new_topic_page)

      lambda {
        new_topic_uri = topic.get_new_topic_uri(1, "OMG!", "Hello World")
        topic.get_new_topic_page(new_topic_uri)
      }.should_not raise_error
    end

    it "should return new topic form when get_new_topic_form called" do
      topic = wwf80_topic
      new_topic_uri = URI.parse("http://example.com/forum/new_topic_form.asp?FID=1")
      new_topic_page = load_fixture_page("wwf80-get-new_topic-form-good-response.html", new_topic_uri, 200, post.config.agent)
      lambda {
        topic.get_new_topic_form(new_topic_page).name.should == 'frmMessageForm'
      }.should_not raise_error
    end

    it "should raise topic error when get_new_topic_form has error" do
      topic = wwf80_topic
      new_topic_uri = URI.parse("http://example.com/forum/new_topic_form.asp?FID=1")
      new_topic_page = load_fixture_page("wwf80-get-new_topic-form-good-response.html", new_topic_uri, 200, post.config.agent)
      new_topic_page.should_receive(:form).with("frmMessageForm").and_return nil
      lambda {
        topic.get_new_topic_form(new_topic_page)
      }.should raise_error( Impostor::TopicError )
    end

    #it "should raise not implemented error when set_subject_and_message called" do
    #  lambda { topic.set_subject_and_message(nil, nil, nil) }.should raise_error(
    #    Impostor::MissingTemplateMethodError,
    #    "Impostor error: set_subject_and_message must be implemented (StandardError)"
    #  )
    #end

    #it "should raise not implemented error when post_new_topic called" do
    #  lambda { topic.post_new_topic(nil) }.should raise_error(
    #    Impostor::MissingTemplateMethodError,
    #    "Impostor error: post_new_topic must be implemented (StandardError)"
    #  )
    #end

    #it "should raise not implemented error when validate_new_topic_result called" do
    #  lambda { topic.validate_new_topic_result(nil) }.should raise_error(
    #    Impostor::MissingTemplateMethodError,
    #    "Impostor error: validate_new_topic_result must be implemented (StandardError)"
    #  )
    #end

    #it "should raise not implemented error when get_topic_from_result called" do
    #  lambda { topic.get_topic_from_result(nil) }.should raise_error(
    #    Impostor::MissingTemplateMethodError,
    #    "Impostor error: get_topic_from_result must be implemented (StandardError)"
    #  )
    #end

  end

end
