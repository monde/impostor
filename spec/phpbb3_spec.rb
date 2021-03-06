require File.join(File.dirname(__FILE__), 'spec_helper')

describe "a phpbb3 impostor" do

  describe "authentication routines" do

    before do
      @auth = phpbb3_auth

      @login_uri = URI.parse("http://example.com/forum/ucp.php?mode=login")

      @reply_uri = URI.parse("http://example.com/forum/posting.php?mode=reply&f=1&t=2")

      @login_page = load_fixture_page(
        "phpbb3-login.html",
        @auth.config.login_page, 200, @auth.config.agent
      )

      @logged_in_page = load_fixture_page(
        "phpbb3-logged-in.html",
        @auth.config.app_root, 200, @auth.config.agent
      )

      @not_logged_in_page = load_fixture_page(
        "phpbb3-not-logged-in.html",
        @auth.config.app_root, 200, @auth.config.agent
      )

      @junk_page = load_fixture_page(
        "junk.html", @reply_uri, 200, @auth.config.agent
      )
    end

    it "should logout only if not logged in" do
      @auth.should_receive(:authenticated?).once.and_return(false)
      @auth.logout.should_not be_true
    end

    it "should logout" do
      @auth.config.should_receive(:save_topics).once
      @auth.config.should_receive(:save_cookie_jar).once
      @auth.instance_variable_set("@authenticated", true)

      @auth.logout.should be_true
      @auth.authenticated?.should_not be_true
    end

    it "should be logged_in? when phpbb3 displays the user name" do
      lambda {
        @auth.logged_in?(@logged_in_page).should be_true
      }.should_not raise_error
    end

    it "should not be logged_in? when phpbb3 does not display the user name" do
      lambda {
        @auth.logged_in?(@not_logged_in_page).should_not be_true
      }.should_not raise_error
    end

    it "should return a page from fetch_login_page" do
      @auth.config.agent.should_receive(:get).with(@login_uri)

      lambda {
        @auth.fetch_login_page
      }.should_not raise_error
    end

    it "should handle an error in fetch_login_page" do
      @auth.config.agent.should_receive(:get).with(@login_uri).and_raise(StandardError)

      lambda {
        @auth.fetch_login_page
      }.should raise_error( Impostor::LoginError )
    end

    it "should return a login form from get_login_form" do
      lambda {
        @auth.get_login_form(@login_page).action.should match(/\/ucp\.php\?mode=login/)
      }.should_not raise_error
    end

    it "should raise login error when get_login_form receives a bad page" do
      lambda {
        @auth.get_login_form(@junk_page)
      }.should raise_error( Impostor::LoginError )
    end

    it "should setup login form in set_username_and_password" do
      form = mock "login form"
      form.should_receive(:[]=).with("username", "tester")
      form.should_receive(:[]=).with("password", "password")
      form.should_receive(:[]=).with("login", "Login")
      form.should_receive(:[]=).with("autologin", "on")
      lambda {
        @auth.set_username_and_password(form).should == form
      }.should_not raise_error
    end

    it "should return a logged in page when posting the login" do
      form = @auth.get_login_form(@login_page)
      @auth.config.agent.should_receive(:submit).with(instance_of(Mechanize::Form), nil, {}).and_return(@logged_in_page)
      lambda {
        @auth.post_login(form).should == @logged_in_page
      }.should_not raise_error
    end

    it "should raise a login error when posting has an underlying exception" do
      form = @auth.get_login_form(@login_page)
      @auth.config.agent.should_receive(:submit).with(instance_of(Mechanize::Form), nil, {}).and_raise(StandardError)
      lambda {
        @auth.post_login(form)
      }.should raise_error( Impostor::LoginError )
    end

    it "should login" do
      @auth.config.agent.should_receive(:get).with(@login_uri).and_return(@login_page)
      @auth.config.agent.should_receive(:submit).with(instance_of(Mechanize::Form), nil, {}).and_return(@logged_in_page)

      lambda {
        @auth.login.should be_true
      }.should_not raise_error
    end
  end

  describe "posting routines" do

    before do
      @post = phpbb3_post

      @reply_uri = URI.parse("http://example.com/forum/posting.php?mode=reply&f=1&t=2")

      @response_uri = URI.parse("http://example.com/forum/viewtopic.php?f=1&t=2&p=355#p355")

      @reply_page = load_fixture_page(
        "phpbb3-get-reply-form-good-response.html",
        @reply_uri, 200, @post.config.agent
      )

      @good_response_page = load_fixture_page(
        "phpbb3-post-reply-good-response.html",
        @response_uri, 200, @post.config.agent
      )

      @junk_page = load_fixture_page(
        "junk.html", @reply_uri, 200, @post.config.agent
      )
    end

    it "should post a message in the topic of a forum" do
      @post.auth.should_receive(:login_with_raises)
      @post.config.agent.should_receive(:get).with(@reply_uri).and_return(@reply_page)
      @post.config.agent.should_receive(:submit).with(instance_of(Mechanize::Form), nil, {}).and_return(@good_response_page)

      lambda {
        @post.post(formum=1, topic=2, message="Hello World").should == {
          :forum => 1,
          :topic => 2,
          :post => 355,
          :message => "Hello World",
          :result => true
        }
      }.should_not raise_error
    end

    it "should get a reply uri from get_reply_uri(forum, topic)" do
      lambda {
        @post.get_reply_uri(1,2).should == @reply_uri
      }.should_not raise_error
    end

    it "should get_reply_page(uri)" do
      @post.config.agent.should_receive(:get).with(@reply_uri).and_return(@reply_page)
      lambda {
        @post.get_reply_page(@reply_uri).should == @reply_page
      }.should_not raise_error
    end

    it "should return reply from with get_post_form(page)" do
      lambda {
        @post.get_post_form(@reply_page).name.should == 'postform'
      }.should_not raise_error
    end

    it "should raise error when page to get_post_form(page) receives a bad page" do
      lambda {
        @post.get_post_form(@junk_page)
      }.should raise_error( Impostor::PostError )
    end

    it "should set_message(form, message)" do
      form = @post.get_post_form(@reply_page)
      form.should_receive(:message=).with("Hello World")
      lambda {
        @post.set_message(form, "Hello World")
      }.should_not raise_error
    end

    it "should return response page from post_message(form)" do
      form = mock "post form"
      form.should_receive(:submit).and_return @reply_page
      lambda {
        @post.post_message(form).should == @reply_page
      }.should_not raise_error
    end

    it "should raise post error when post_form fails" do
      form = mock "post form"
      form.should_receive(:submit).and_raise( Impostor::PostError )
      lambda {
        @post.post_message(form)
      }.should raise_error( Impostor::PostError )
    end

    it "should not raise post error on valid reply get_post_from_result(page)" do
      lambda {
        @post.get_post_from_result(@good_response_page).should == 355
      }.should_not raise_error
    end

    it "should raise post error on invalid reply get_post_from_result(page)" do
      lambda {
        @post.get_post_from_result(@junk_page)
      }.should raise_error( Impostor::PostError )
    end

  end

  describe "topic routines" do

    before do
      @topic = phpbb3_topic

      @new_topic_uri = URI.parse("http://example.com/forum/posting.php?mode=post&f=1")

      @new_topic_page = load_fixture_page(
        "phpbb3-get-new-topic-form-good-response.html",
        @new_topic_uri, 200, @topic.config.agent
      )

      @new_topic_good_result_uri = URI.parse("http://example.com/forum/viewtopic.php?f=1&t=2&p=325")

      @new_topic_good_result = load_fixture_page(
        "phpbb3-post-new_topic-good-response.html",
        @new_topic_good_result_uri, 200, @topic.config.agent
      )
    end

    it "should return new topic uri when get_new_topic_uri called" do
      lambda {
        @topic.get_new_topic_uri(1, "OMG!", "Hello World").should == @new_topic_uri
      }.should_not raise_error
    end

    it "should return new topic page when get_new_topic_page called" do
      @topic.config.agent.should_receive(:get).with(@new_topic_uri).and_return(@new_topic_page)

      lambda {
        @topic.get_new_topic_page(@new_topic_uri).should == @new_topic_page
      }.should_not raise_error
    end

    it "should return new topic form when get_new_topic_form called" do
      lambda {
        @topic.get_new_topic_form(@new_topic_page).name.should == 'postform'
      }.should_not raise_error
    end

    it "should raise topic error when get_new_topic_form has error" do
      @new_topic_page.should_receive(:forms).and_return []
      lambda {
        @topic.get_new_topic_form(@new_topic_page)
      }.should raise_error( Impostor::TopicError )
    end

    it "should set subject and message on a form when set_subject_and_message called" do
      form = mock "phpbb3 topic form"
      form.should_receive(:subject=).with("OMG!")
      form.should_receive(:message=).with("Hello World")
      form.should_receive(:[]=).with("post", "Submit")
      lambda {
        @topic.set_subject_and_message(form, "OMG!", "Hello World")
      }.should_not raise_error
    end

    it "should post new topic with form when post_new_topic called" do
      @topic.config.agent.should_receive(:submit).with(instance_of(Mechanize::Form), nil, {}).and_return(@new_topic_good_result)
      new_topic_form = @topic.get_new_topic_form(@new_topic_page)
      lambda {
        @topic.post_new_topic(new_topic_form)
      }.should_not raise_error
    end

    it "should raise topic error when posting_new_topic has an error" do
      form = mock "a phpbb3 form"
      form.should_receive(:submit).and_raise(StandardError)
      lambda {
        @topic.post_new_topic(form)
      }.should raise_error( Impostor::TopicError )
    end

    it "should not raise topic error on valid reply validate_new_topic_result(page)" do
      lambda {
        @topic.validate_new_topic_result(@new_topic_good_result).should == @new_topic_good_result
      }.should_not raise_error
    end

    it "should return the created topic id from get_topic_from_result" do
      lambda {
        @topic.get_topic_from_result(@new_topic_good_result).should == 205
      }.should_not raise_error
    end

    it "should create new topic" do
      @topic.auth.should_receive(:login_with_raises)
      @topic.config.agent.should_receive(:get).with(@new_topic_uri).and_return(@new_topic_page)
      @topic.config.agent.should_receive(:submit).with(instance_of(Mechanize::Form), nil, {}).and_return(@new_topic_good_result)
      @topic.config.should_receive(:add_subject).with(1, 205, "OMG!")

      lambda {
        @topic.new_topic(formum=1, subject="OMG!", message="Hello World").should == {
          :forum => 1,
          :topic => 205,
          :subject => "OMG!",
          :message => "Hello World",
          :result => true
        }
      }.should_not raise_error
    end
  end

end

