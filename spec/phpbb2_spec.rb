require File.join(File.dirname(__FILE__), 'spec_helper')

describe "a phpbb2 impostor" do

  describe "authentication routines" do

    it "should logout only if not logged in" do
      auth = phpbb2_auth
      auth.should_receive(:authenticated?).once.and_return(false)
      auth.logout.should_not be_true
    end

    it "should logout" do
      auth = phpbb2_auth
      auth.config.should_receive(:save_topics).once
      auth.config.should_receive(:save_cookie_jar).once
      auth.instance_variable_set("@authenticated", true)

      auth.logout.should be_true
      auth.authenticated?.should_not be_true
    end

    it "should be logged_in? when phpbb2 displays the user name" do
      auth = phpbb2_auth
      page = load_fixture_page("phpbb2-logged-in.html", auth.config.app_root, 200, auth.config.agent)

      lambda {
        auth.logged_in?(page).should be_true
      }.should_not raise_error
    end

    it "should not be logged_in? when phpbb2 does not display the user name" do
      auth = phpbb2_auth
      page = load_fixture_page("phpbb2-not-logged-in.html", auth.config.app_root, 200, auth.config.agent)

      lambda {
        auth.logged_in?(page).should_not be_true
      }.should_not raise_error
    end

    it "should return a page from fetch_login_page" do
      auth = phpbb2_auth
      login_uri = URI.parse("http://example.com/forum/login.php")
      auth.config.agent.should_receive(:get).with(login_uri)

      lambda {
        auth.fetch_login_page
      }.should_not raise_error
    end

    it "should handle an error in fetch_login_page" do
      auth = phpbb2_auth
      login_uri = URI.parse("http://example.com/forum/login.php")
      auth.config.agent.should_receive(:get).with(login_uri).and_raise(StandardError)

      lambda {
        auth.fetch_login_page
      }.should raise_error( Impostor::LoginError )
    end

    it "should return a login form from get_login_form" do
      auth = phpbb2_auth
      page = load_fixture_page("phpbb2-login.html", auth.config.login_page, 200, auth.config.agent)

      lambda {
        auth.get_login_form(page).action.should match(/login\.php/)
      }.should_not raise_error
    end

    it "should raise login error when get_login_form receives a bad page" do
      auth = phpbb2_auth
      page = load_fixture_page("junk.html", auth.config.login_page, 200, auth.config.agent)

      lambda {
        auth.get_login_form(page)
      }.should raise_error( Impostor::LoginError )
    end

    it "should setup login form in set_username_and_password" do
      auth = phpbb2_auth
      form = mock "login form"
      form.should_receive(:[]=).with("username", "tester")
      form.should_receive(:[]=).with("password", "pass")
      form.should_receive(:[]=).with("autologin", "on")
      lambda {
        auth.set_username_and_password(form).should == form
      }.should_not raise_error
    end

    it "should return a logged in page when posting the login" do
      auth = phpbb2_auth
      login_page = load_fixture_page("phpbb2-login.html", auth.config.login_page, 200, auth.config.agent)
      form = auth.get_login_form(login_page)
      logged_in_page = load_fixture_page("phpbb2-logged-in.html", auth.config.app_root, 200, auth.config.agent)
      auth.config.agent.should_receive(:submit).with(instance_of(Mechanize::Form), nil, {}).and_return(logged_in_page)
      lambda {
        auth.post_login(form).should == logged_in_page
      }.should_not raise_error
    end

    it "should raise a login error when posting has an underlying exception" do
      auth = phpbb2_auth
      login_page = load_fixture_page("phpbb2-login.html", auth.config.login_page, 200, auth.config.agent)
      form = auth.get_login_form(login_page)
      logged_in_page = load_fixture_page("phpbb2-logged-in.html", auth.config.app_root, 200, auth.config.agent)
      auth.config.agent.should_receive(:submit).with(instance_of(Mechanize::Form), nil, {}).and_raise(StandardError)
      lambda {
        auth.post_login(form)
      }.should raise_error( Impostor::LoginError )
    end

    it "should login" do
      auth = phpbb2_auth
      login_page = load_fixture_page("phpbb2-login.html", auth.config.login_page, 200, auth.config.agent)
      logged_in_page = load_fixture_page("phpbb2-logged-in.html", auth.config.app_root, 200, auth.config.agent)
      login_uri = URI.parse("http://example.com/forum/login.php")

      auth.config.agent.should_receive(:get).with(login_uri).and_return(login_page)
      auth.config.agent.should_receive(:submit).with(instance_of(Mechanize::Form), nil, {}).and_return(logged_in_page)

      lambda {
        auth.login.should be_true
      }.should_not raise_error
    end
  end

  describe "posting routines" do

    it "should post a message in the topic of a forum" do
      post = phpbb2_post
      post.auth.should_receive(:login_with_raises)
      reply_uri = URI.parse("http://example.com/forum/posting.php?mode=reply&t=2")
      reply_page = load_fixture_page("phpbb2-get-new_topic-form-good-response.html", reply_uri, 200, post.config.agent)
      post.config.agent.should_receive(:get).with(reply_uri).and_return(reply_page)
      response_uri = URI.parse(post.config.app_root)
      response_page = load_fixture_page("phpbb2-post-reply-good-response.html", response_uri, 200, post.config.agent)
      post.config.agent.should_receive(:submit).with(instance_of(Mechanize::Form), nil, {}).and_return(response_page)

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
      post = phpbb2_post
      reply_uri = URI.parse("http://example.com/forum/posting.php?mode=reply&t=2")
      lambda {
        post.get_reply_uri(1,2).should == reply_uri
      }.should_not raise_error
    end

    it "should get_reply_page(uri)" do
      post = phpbb2_post
      reply_uri = URI.parse("http://example.com/forum/posting.php")
      reply_page = load_fixture_page("phpbb2-get-new_topic-form-good-response.html", reply_uri, 200, post.config.agent)

      post.config.agent.should_receive(:get).with(reply_uri).and_return(reply_page)
      lambda {
        post.get_reply_page(reply_uri).should == reply_page
      }.should_not raise_error
    end

    it "should return reply from with get_post_form(page)" do
      post = phpbb2_post
      reply_uri = URI.parse("http://example.com/forum/posting.php")
      reply_page = load_fixture_page("phpbb2-get-new_topic-form-good-response.html", reply_uri, 200, post.config.agent)
      lambda {
        post.get_post_form(reply_page).name.should == 'post'
      }.should_not raise_error
    end

    it "should raise error when page to get_post_form(page) receives a bad page" do
      post = phpbb2_post
      reply_uri = URI.parse("http://example.com/forum/posting.php")

      page = load_fixture_page("junk.html", reply_uri, 200, post.config.agent)

      lambda {
        post.get_post_form(page)
      }.should raise_error( Impostor::PostError )
    end

    it "should set_message(form, message)" do
      post = phpbb2_post
      reply_uri = URI.parse("http://example.com/forum/posting.php")
      reply_page = load_fixture_page("phpbb2-get-new_topic-form-good-response.html", reply_uri, 200, post.config.agent)
      form = post.get_post_form(reply_page)
      form.should_receive(:message=, "Hello World")
      lambda {
        post.set_message(form, "Hello World")
      }.should_not raise_error
    end

    it "should return response page from post_message(form)" do
      post = phpbb2_post
      form = mock "post form"
      reply_page = mock "reply page"
      form.should_receive(:submit).and_return reply_page
      lambda {
        post.post_message(form).should == reply_page
      }.should_not raise_error
    end

    it "should raise post error when post_form fails" do
      post = phpbb2_post
      form = mock "post form"
      form.should_receive(:submit).and_raise( Impostor::PostError )
      lambda {
        post.post_message(form)
      }.should raise_error( Impostor::PostError )
    end

    it "should not raise post error on valid reply validate_post_result(page)" do
      post = phpbb2_post

      page = load_fixture_page("phpbb2-post-reply-good-response.html", auth.config.app_root, 200, post.config.agent)
      #lambda {
        post.validate_post_result(page).should be_true
      #}.should_not raise_error
    end

    it "should raise post error on invalid reply validate_post_result(page)" do
      post = phpbb2_post
      page = load_fixture_page("junk.html", post.config.app_root, 200, post.config.agent)
      lambda {
        post.validate_post_result(page)
      }.should raise_error( Impostor::PostError )
    end

  end

end

