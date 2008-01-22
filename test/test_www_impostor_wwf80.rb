require File.join(File.dirname(__FILE__), "..", "lib", "impostor")
require File.join(File.dirname(__FILE__), "..", "lib", "impostor", "wwf80")
require File.join(File.dirname(__FILE__), "test_helper")

require 'test/unit'
require 'rubygems'
require 'mocha'
require 'mechanize'

class WWW::Impostor::Wwf80Test < Test::Unit::TestCase
  include TestHelper

  def setup
    @cookie_jar = File.join(Dir.tmpdir, 'www_impostor_wwf80_test.yml')
    @app_root = 'http://localhost/wwf80/'
    @im = WWW::Impostor::Wwf80.new(config())
  end

  def teardown
    File.delete(@cookie_jar) if File.exist?(@cookie_jar)
  end

  def config(config={})
    c = {:app_root => @app_root,
      :login_page => 'login_user.asp', 
      :new_reply_page => 'new_reply_form.asp',
      :new_topic_page => 'new_topic_form.asp',
      :user_agent => 'Windows IE 7', 
      :username => 'tester',
      :password => 'test',
      :cookie_jar => @cookie_jar
      }.merge(config)
    c
  end

  def wwf80_good_submit_post_form
    %q!<form action="post_message.asp?PN=" method="post" name="frmAddMessage">
    <input name="message" value="" type="hidden">
    <input name="Submit" type="submit">
    </form>!
  end

  def wwf80_good_submit_new_topic_form
    %q!<form action="post_message.asp?PN=" method="post" name="frmAddMessage">
    <input name="subject" type="text">
    <input name="message" value="" type="hidden">
    <input name="Submit" type="submit">
    </form>!
  end

  def test_initialize_with_cookie_jar
    FileUtils.touch(@cookie_jar)

    WWW::Mechanize::CookieJar.any_instance.expects(:load).once.with(@cookie_jar)
    im = WWW::Impostor::Wwf80.new(config())
    assert im
  end

  def test_initialize_without_cookie_jar
    WWW::Mechanize::CookieJar.any_instance.expects(:load).never
    im = WWW::Impostor::Wwf80.new(config())
    assert im
  end

  def test_version
    assert @im.version
  end

=begin
  def test_should_be_logged_in?
    response = {'content-type' => 'text/html'}
    body = load_page('wwf80-logged-in.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    assert_equal true, @im.send(:logged_in?, page)
  end

  def test_should_not_be_logged_in?
    response = {'content-type' => 'text/html'}
    body = load_page('wwf80-not-logged-in.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    assert_equal false, @im.send(:logged_in?, page)
  end

  def test_fetch_login_page
    page = load_page('wwf80-login.html').join
    WWW::Mechanize.any_instance.expects(:get).once.with(
      URI.join(@app_root, config[:login_page])
    ).returns(page)
    
    assert_equal page, @im.send(:fetch_login_page)
  end

  def test_login_form_and_button_should_raise_login_error_when_form_is_missing
    err = assert_raise(WWW::Impostor::LoginError) do
      form, button = @im.send(:login_form_and_button, nil)
    end
    assert_equal "unknown login page format", err.original_exception.message
  end

  def test_login_form_and_button_should_return_a_form_and_button
    response = {'content-type' => 'text/html'}
    body = load_page('wwf80-login.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    form, button = @im.send(:login_form_and_button, page)
    assert_equal true, form.is_a?(WWW::Mechanize::Form)
    assert_equal true, button.is_a?(WWW::Mechanize::Button)
  end

  def test_post_login_should_return_page
    response = {'content-type' => 'text/html'}
    body = load_page('wwf80-logged-in.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    form = mock()
    button = mock()
    WWW::Mechanize.any_instance.expects(:submit).once.with(form, button).returns(page)

    assert_equal page, @im.send(:post_login, form, button)
  end

  def test_post_login_should_raise_login_error
    errmsg = "from test #{Time.now.to_s}"
    WWW::Mechanize.any_instance.expects(:submit).raises(StandardError, errmsg)
    err = assert_raise(WWW::Impostor::LoginError) do
      page = @im.send(:post_login, nil, nil)
    end
    assert_equal errmsg, err.original_exception.message
  end

  def test_bad_login_page_should_raise_exception
    errmsg = "from test #{Time.now.to_s}"
    WWW::Mechanize.any_instance.expects(:get).once.with(
      URI.join(@app_root, config[:login_page])
    ).raises(StandardError, errmsg)

    err = assert_raise(WWW::Impostor::LoginError) do
      @im.send(:fetch_login_page)
    end
    assert_equal errmsg, err.original_exception.message
  end

  def test_already_logged_in_should_not_post_login_information_again_instance_varialbe
    @im.instance_variable_set(:@loggedin, true)
    @im.expects(:fetch_login_page).never
    assert_equal true, @im.login
  end

  def test_already_logged_in_should_not_post_login_information_again
    @im.instance_variable_set(:@loggedin, false)
    page = mock()
    @im.stubs(:fetch_login_page).returns(page)
    @im.expects(:logged_in?).once.with(page).returns(true)
    @im.expects(:login_form_and_button).with(page).never
    @im.login
  end

  def test_login_should_login
    @im.instance_variable_set(:@loggedin, false)
    login_page = mock()
    @im.stubs(:fetch_login_page).returns(login_page)
    @im.expects(:logged_in?).once.with(login_page).returns(false)
    form = mock()
    button = mock()
    @im.expects(:login_form_and_button).with(login_page).returns([form, button])
    logged_in_page = mock()
    @im.expects(:post_login).with(form, button).returns(logged_in_page)
    @im.expects(:logged_in?).once.with(logged_in_page).returns(true)
    @im.expects(:load_topics).once.returns(true)

    assert_equal true, @im.login
  end

  def test_logout_does_nothing_if_logged_out
    @im.instance_variable_set(:@loggedin, false)
    @im.expects(:cookie_jar).never
    @im.expects(:save_topics).never
    assert_equal false, @im.logout
  end

  def test_logout
    @im.instance_variable_set(:@loggedin, true)
    cookie_jar = mock()
    @im.expects(:cookie_jar).times(2).returns(cookie_jar)
    WWW::Mechanize::CookieJar.any_instance.expects(:save_as).once.with(cookie_jar).returns(nil)
    @im.expects(:save_topics).once
    assert_equal true, @im.logout
    assert_equal nil, @im.instance_variable_get(:@forum)
    assert_equal nil, @im.instance_variable_get(:@topic)
    assert_equal nil, @im.instance_variable_get(:@subject)
    assert_equal nil, @im.instance_variable_get(:@message)
    assert_equal false, @im.instance_variable_get(:@loggedin)
  end

  def test_forum_posts_page
    c = config
    assert_equal URI.join(@app_root, c[:forum_posts_page]), @im.forum_posts_page
  end

  def test_post_message_page
    c = config
    assert_equal URI.join(@app_root, c[:post_message_page]), @im.post_message_page
  end

  def test_post_without_forum_set_should_raise_exception
    @im.instance_variable_set(:@forum, nil)
    err = assert_raise(WWW::Impostor::PostError) do
      @im.post
    end
    assert_equal "forum not set", err.original_exception.message
    err = assert_raise(WWW::Impostor::PostError) do
      @im.post(f=nil,t=nil,m=nil)
    end
    assert_equal "forum not set", err.original_exception.message
  end

  def test_post_without_topic_set_should_raise_exception
    @im.instance_variable_set(:@forum, 1)
    @im.instance_variable_set(:@topic, nil)
    err = assert_raise(WWW::Impostor::PostError) do
      @im.post
    end
    assert_equal "topic not set", err.original_exception.message
    err = assert_raise(WWW::Impostor::PostError) do
      @im.post(f=2,t=nil,m=nil)
    end
    assert_equal "topic not set", err.original_exception.message
  end

  def test_post_without_message_set_should_raise_exception
    @im.instance_variable_set(:@forum, 1)
    @im.instance_variable_set(:@topic, 1)
    @im.instance_variable_set(:@message, nil)
    err = assert_raise(WWW::Impostor::PostError) do
      @im.post
    end
    assert_equal "message not set", err.original_exception.message
    err = assert_raise(WWW::Impostor::PostError) do
      @im.post(f=2,t=2,m=nil)
    end
    assert_equal "message not set", err.original_exception.message
  end

  def test_post_not_logged_in_should_raise_exception
    @im.expects(:login).once.returns(false)
    @im.instance_variable_set(:@loggedin, false)
    err = assert_raise(WWW::Impostor::PostError) do
      @im.post(2,2,'hello')
    end
    assert_equal "not logged in", err.original_exception.message
  end

  def test_bad_post_page_for_post_should_raise_exception
    @im.instance_variable_set(:@loggedin, true)
    topic = 2
    forum_posts_page = @im.forum_posts_page
    forum_posts_page.query = "TID=#{topic}&TPN=10000"
    errmsg = "from test #{Time.now.to_s}"
    WWW::Mechanize.any_instance.expects(:get).once.with(
      forum_posts_page
    ).raises(StandardError, errmsg)
    err = assert_raise(WWW::Impostor::PostError) do
      @im.post(7,topic,'hello')
    end
    assert_equal errmsg, err.original_exception.message
  end

  def test_bad_post_form_for_post_should_raise_exception
    @im.instance_variable_set(:@loggedin, true)
    response = {'content-type' => 'text/html'}
    body = '<form action="post_message.asp?PN=" method="post" name="frmAddMessage"></form>'
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    topic = 2
    forum_posts_page = @im.forum_posts_page
    forum_posts_page.query = "TID=#{topic}&TPN=10000"
    WWW::Mechanize.any_instance.expects(:get).once.with(forum_posts_page).returns(page)
    err = assert_raise(WWW::Impostor::PostError) do
      @im.post(1,topic,'hello')
    end
    assert_equal "post form not found", err.original_exception.message
  end

  def test_submitting_bad_post_form_for_post_should_raise_exception
    @im.instance_variable_set(:@loggedin, true)
    response = {'content-type' => 'text/html'}
    body = wwf80_good_submit_post_form
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    topic = 2
    forum_posts_page = @im.forum_posts_page
    forum_posts_page.query = "TID=#{topic}&TPN=10000"
    WWW::Mechanize.any_instance.expects(:get).once.with(forum_posts_page).returns(page)
    errmsg = "from test #{Time.now.to_s}"
    WWW::Mechanize.any_instance.expects(:submit).once.raises(StandardError, errmsg)
    err = assert_raise(WWW::Impostor::PostError) do
      @im.post(1,topic,'hello')
    end
    assert_equal errmsg, err.original_exception.message
  end

  def test_too_many_posts_for_post_should_raise_exception
    @im.instance_variable_set(:@loggedin, true)
    response = {'content-type' => 'text/html'}
    body = wwf80_good_submit_post_form
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    topic = 2
    forum_posts_page = @im.forum_posts_page
    forum_posts_page.query = "TID=#{topic}&TPN=10000"
    WWW::Mechanize.any_instance.expects(:get).once.with(forum_posts_page).returns(page)
    body = load_page('wwf80-too-many-posts.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    WWW::Mechanize.any_instance.expects(:submit).once.returns(page)

    err = assert_raise(WWW::Impostor::ThrottledError) do
      @im.post(1,topic,'hello')
    end
    assert_equal "You have exceeded the number of posts permitted in the time span", err.original_exception.message
  end

  def test_getting_unknown_post_response_should_raise_exception
    @im.instance_variable_set(:@loggedin, true)
    response = {'content-type' => 'text/html'}
    body = wwf80_good_submit_post_form
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    topic = 2
    forum_posts_page = @im.forum_posts_page
    forum_posts_page.query = "TID=#{topic}&TPN=10000"
    WWW::Mechanize.any_instance.expects(:get).once.with(forum_posts_page).returns(page)
    body = load_page('wwf80-general-posting-error.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    WWW::Mechanize.any_instance.expects(:submit).once.returns(page)

    err = assert_raise(WWW::Impostor::PostError) do
      @im.post(1,topic,'hello')
    end
    assert_equal "There was an error making the post", err.original_exception.message
  end

  def test_should_post
    @im.instance_variable_set(:@loggedin, true)
    response = {'content-type' => 'text/html'}
    body = wwf80_good_submit_post_form
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    topic = 2
    forum_posts_page = @im.forum_posts_page
    forum_posts_page.query = "TID=#{topic}&TPN=10000"
    WWW::Mechanize.any_instance.expects(:get).once.with(forum_posts_page).returns(page)
    body = load_page('wwf80-good-post-forum_posts.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    WWW::Mechanize.any_instance.expects(:submit).once.returns(page)
    subject = "test #{Time.now.to_s}"
    @im.expects(:get_subject).once.returns(subject)

    assert_equal true, @im.post(1,topic,'hello')
    assert_equal 1, @im.instance_variable_get(:@forum)
    assert_equal topic, @im.instance_variable_get(:@topic)
    assert_equal subject, @im.instance_variable_get(:@subject)
    assert_equal 'hello', @im.instance_variable_get(:@message)
  end

  def test_new_topic_without_forum_set_should_raise_exception
    @im.instance_variable_set(:@forum, nil)
    err = assert_raise(WWW::Impostor::PostError) do
      @im.new_topic
    end
    assert_equal "forum not set", err.original_exception.message
    err = assert_raise(WWW::Impostor::PostError) do
      @im.new_topic(f=nil,s="hello world",m="hello world")
    end
    assert_equal "forum not set", err.original_exception.message
  end

  def test_new_topic_without_subject_set_should_raise_exception
    @im.instance_variable_set(:@forum, 1)
    @im.instance_variable_set(:@subject, nil)
    err = assert_raise(WWW::Impostor::PostError) do
      @im.new_topic
    end
    assert_equal "topic name not given", err.original_exception.message
    err = assert_raise(WWW::Impostor::PostError) do
      @im.new_topic(f=1,s=nil,m="hello world")
    end
    assert_equal "topic name not given", err.original_exception.message
  end

  def test_new_topic_without_message_set_should_raise_exception
    @im.instance_variable_set(:@forum, 1)
    @im.instance_variable_set(:@subject, 'test')
    @im.instance_variable_set(:@message, nil)
    err = assert_raise(WWW::Impostor::PostError) do
      @im.new_topic
    end
    assert_equal "message not set", err.original_exception.message
    err = assert_raise(WWW::Impostor::PostError) do
      @im.new_topic(f=1,s="hello world",m=nil)
    end
    assert_equal "message not set", err.original_exception.message
  end

  def test_new_topic_not_logged_in_should_raise_exception
    @im.expects(:login).once.returns(false)
    @im.instance_variable_set(:@loggedin, false)

    err = assert_raise(WWW::Impostor::PostError) do
      @im.new_topic(f=2,s="hello world",m="hello ruby")
    end
    assert_equal "not logged in", err.original_exception.message
  end

  def test_getting_bad_post_page_for_new_topic_should_raise_exception
    @im.instance_variable_set(:@loggedin, true)
    forum = 2
    post_message_page = @im.post_message_page
    post_message_page.query = "FID=#{forum}"
    errmsg = "from test #{Time.now.to_s}"
    WWW::Mechanize.any_instance.expects(:get).once.with(
      post_message_page
    ).raises(StandardError, errmsg)

    err = assert_raise(WWW::Impostor::PostError) do
      @im.new_topic(f=forum,s="hello world",m="hello ruby")
    end
    assert_equal errmsg, err.original_exception.message
  end

  def test_getting_bad_post_form_for_new_topic_should_raise_exception
    @im.instance_variable_set(:@loggedin, true)
    response = {'content-type' => 'text/html'}
    body = '<form action="post_message.asp?PN=" method="post" name="frmAddMessage"></form>'
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    forum = 2
    post_message_page = @im.post_message_page
    post_message_page.query = "FID=#{forum}"
    WWW::Mechanize.any_instance.expects(:get).once.with(post_message_page).returns(page)
    err = assert_raise(WWW::Impostor::PostError) do
      @im.new_topic(f=forum,s="hello world",m="hello ruby")
    end
    assert_equal "post form not found", err.original_exception.message
  end

  def test_submitting_bad_post_for_new_topic_form_should_raise_exception
    @im.instance_variable_set(:@loggedin, true)
    response = {'content-type' => 'text/html'}
    body = wwf80_good_submit_new_topic_form
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    forum = 2
    post_message_page = @im.post_message_page
    post_message_page.query = "FID=#{forum}"
    WWW::Mechanize.any_instance.expects(:get).once.with(post_message_page).returns(page)
    errmsg = "from test #{Time.now.to_s}"
    WWW::Mechanize.any_instance.expects(:submit).once.raises(StandardError, errmsg)
    err = assert_raise(WWW::Impostor::PostError) do
      @im.new_topic(f=forum,s="hello world",m="hello ruby")
    end
    assert_equal errmsg, err.original_exception.message
  end

  def test_too_many_posts_for_new_topic_should_raise_exception
    @im.instance_variable_set(:@loggedin, true)
    response = {'content-type' => 'text/html'}
    body = wwf80_good_submit_new_topic_form
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    forum = 2
    post_message_page = @im.post_message_page
    post_message_page.query = "FID=#{forum}"
    WWW::Mechanize.any_instance.expects(:get).once.with(post_message_page).returns(page)
    body = load_page('wwf80-too-many-topics.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    WWW::Mechanize.any_instance.expects(:submit).once.returns(page)

    err = assert_raise(WWW::Impostor::ThrottledError) do
      @im.new_topic(f=forum,s="hello world",m="hello ruby")
    end
    assert_equal "You have exceeded the number of posts permitted in the time span", err.original_exception.message
  end

  def test_getting_unknown_new_topic_response_should_raise_exception
    @im.instance_variable_set(:@loggedin, true)
    response = {'content-type' => 'text/html'}
    body = wwf80_good_submit_new_topic_form
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    forum = 2
    post_message_page = @im.post_message_page
    post_message_page.query = "FID=#{forum}"
    WWW::Mechanize.any_instance.expects(:get).once.with(post_message_page).returns(page)
    body = load_page('wwf80-general-new-topic-error.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    WWW::Mechanize.any_instance.expects(:submit).once.returns(page)

    err = assert_raise(WWW::Impostor::PostError) do
      @im.new_topic(f=forum,s="hello world",m="hello ruby")
    end
    assert_equal "There was an error creating the topic", err.original_exception.message
  end

  def test_malformed_form_with_topicid_for_new_topic_should_raise_exception
    @im.instance_variable_set(:@loggedin, true)
    response = {'content-type' => 'text/html'}
    body = wwf80_good_submit_new_topic_form
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    forum = 2
    post_message_page = @im.post_message_page
    post_message_page.query = "FID=#{forum}"
    WWW::Mechanize.any_instance.expects(:get).once.with(post_message_page).returns(page)

    body = 'junk'
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    WWW::Mechanize.any_instance.expects(:submit).once.returns(page)

    err = assert_raise(WWW::Impostor::PostError) do
      @im.new_topic(f=forum,s="hello world",m="hello ruby")
    end
    assert_equal "unexpected new topic ID", err.original_exception.message
  end

  def test_new_topic_should_work
    @im.instance_variable_set(:@loggedin, true)
    response = {'content-type' => 'text/html'}
    body = wwf80_good_submit_new_topic_form
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    forum = 2
    subject = "hello world"
    message = "hello ruby"
    post_message_page = @im.post_message_page
    post_message_page.query = "FID=#{forum}"
    WWW::Mechanize.any_instance.expects(:get).once.with(post_message_page).returns(page)
    body = load_page('wwf80-new-topic-forum_posts-response.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    WWW::Mechanize.any_instance.expects(:submit).once.returns(page)

    @im.expects(:add_subject).once.with(forum,357,subject)
    assert_equal true, @im.new_topic(f=forum,s=subject,m=message)
    assert_equal forum, @im.instance_variable_get(:@forum)
    assert_equal 357, @im.instance_variable_get(:@topic)
    assert_equal subject, @im.instance_variable_get(:@subject)
    assert_equal message, @im.instance_variable_get(:@message)
  end
=end
end
