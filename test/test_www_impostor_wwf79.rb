require File.join(File.dirname(__FILE__), "..", "lib", "impostor")
require File.join(File.dirname(__FILE__), "..", "lib", "impostor", "wwf79")
require File.join(File.dirname(__FILE__), "test_helper")

require 'test/unit'
require 'rubygems'
require 'mocha'
require 'mechanize'

class WWW::Impostor::Wwf79Test < Test::Unit::TestCase
  include TestHelper

  def setup
    @cookie_jar = File.join(Dir.tmpdir, 'www_impostor_wwf79_test.yml')
    @app_root = 'http://localhost/wwf79/'
    @im = WWW::Impostor::Wwf79.new(config())
  end

  def teardown
    File.delete(@cookie_jar) if File.exist?(@cookie_jar)
  end

  def config(config={})
    c = {:app_root => @app_root,
      :login_page => 'login_user.asp', 
      :forum_posts_page => 'forum_posts.asp', 
      :post_message_page => 'post_message_form.asp', 
      :user_agent => 'Windows IE 7', 
      :username => 'tester',
      :password => 'test',
      :cookie_jar => @cookie_jar
      }.merge(config)
    c
  end

  def test_initialize_with_cookie_jar
    FileUtils.touch(@cookie_jar)

    WWW::Mechanize::CookieJar.any_instance.expects(:load).once.with(@cookie_jar)
    im = WWW::Impostor::Wwf79.new(config())
    assert im
  end

  def test_initialize_without_cookie_jar
    WWW::Mechanize::CookieJar.any_instance.expects(:load).never
    im = WWW::Impostor::Wwf79.new(config())
    assert im
  end

  def test_version
    assert @im.version
  end

=begin
  def test_fetch_login_page
    register_good_index
    register_good_login
    page = fake(config).test_fetch_login_page 
    assert page
  end

  def test_bad_login_page_should_raise_exception
    FakeWeb.register_uri(@good_login, :method => :get, 
                         :response => response("not found",404))

    im = WWW::Impostor::Wwf79.new(config(cookies=false))

    assert_raises(WWW::Impostor::LoginError) do
      im.login
    end
  end

  def test_bad_login_post_should_raise_exception
    register_good_index
    FakeWeb.register_uri(@good_login, :method => :get, 
                         :response => response(load_page('wwf79-login.html')))
    FakeWeb.register_uri(@good_login, :method => :post, 
                         :response => response("not found",404))

    im = WWW::Impostor::Wwf79.new(config(cookies=false))

    assert_raises(WWW::Impostor::LoginError) do
      im.login
    end
  end

  def test_should_login
    register_good_index
    register_good_login
    im = WWW::Impostor::Wwf79.new(config(cookies=false))
    assert_equal true, im.login
    im.logout
  end

  def test_posting_without_forum_set_should_raise_exception
    setup_good_fake_web
    im = fake(config)
    im.fake_loggedin = true

    im.forum = nil
    im.topic = 2
    im.message = "hello ruby"
    # topic not set so posting should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.post
    end
    assert_raises(WWW::Impostor::PostError) do
      assert im.post(f=nil,t=2,m="hello ruby")
    end
  end

  def test_posting_without_topic_set_should_raise_exception
    setup_good_fake_web
    im = fake(config)
    im.fake_loggedin = true

    im.forum = 2
    im.topic = nil
    im.message = "hello ruby"
    # topic not set so posting should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.post
    end
    assert_raises(WWW::Impostor::PostError) do
      assert im.post(f=2,t=nil,m="hello ruby")
    end
  end

  def test_posting_without_message_set_should_raise_exception
    setup_good_fake_web
    im = fake(config)

    im.forum = 2
    im.topic = 2
    im.message = nil
    # message is not set so posting should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.post
    end
    assert_raises(WWW::Impostor::PostError) do
      assert im.post(f=2,t=2,m=nil)
    end
  end

  def test_posting_not_logged_in_should_raise_exception
    setup_good_fake_web
    FakeWeb.register_uri(@good_login + '?FID=0', :method => :post, 
      :response => response(load_page('wwf79-not-logged-in.html')))
    im = fake(config)

    im.forum = 2
    im.topic = 2
    im.message = "hello ruby"
    # not logged in so posting should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.post
    end
  end

  def test_getting_bad_posting_for_post_page_should_raise_exception
    setup_good_fake_web

    FakeWeb.register_uri(@good_reply_form + '?TID=2', :method => :get, 
                         :response => response("not found",404))

    im = fake(config)

    im.forum = 2
    im.topic = 2
    im.message = "hello ruby"
    # bad posting page should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.post
    end
  end

  def test_bad_submit_for_post_response_should_raise_exception
    setup_good_fake_web

    FakeWeb.register_uri(@good_reply_form + '?TID=2', :method => :get, 
                         :response => response("not found",404))

    im = fake(config)

    # bad submit should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.post(f=2,t=2,m="hello ruby")
    end
  end

  def test_too_many_posts_for_post_should_raise_throttle_error
    setup_good_fake_web

    FakeWeb.register_uri(@good_posting, :method => :post, 
      :response => response(load_page('wwf79-too-many-posts.html')))

    im = fake(config)

    im.forum = 2
    im.topic = 2
    im.message = "hello ruby"
    # bad posting page should throw an exception
    assert_raises(WWW::Impostor::ThrottledError) do
      assert im.post
    end
  end

  def test_should_post
    setup_good_fake_web

    im = fake(config)
    im.fake_loggedin = true

    im.forum = 2
    im.topic = 2
    im.message = "#{Time.now} Hello there #{Time.now}"
    assert im.post
  end

  def test_new_topic_without_forum_set_should_raise_exception
    setup_good_fake_web
    im = fake(config)
    im.fake_loggedin = true

    im.forum = nil
    im.subject = "hello world"
    im.message = "hello ruby"
    # topic not set so posting should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.new_topic
    end
    assert_raises(WWW::Impostor::PostError) do
      assert im.new_topic(f=nil,s="hello world",m="hello world")
    end
  end

  def test_new_topic_without_subject_set_should_raise_exception
    setup_good_fake_web
    im = fake(config)
    im.fake_loggedin = true

    im.forum = 2
    im.subject = nil
    im.message = "hello ruby"
    # topic not set so posting should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.new_topic
    end
    assert_raises(WWW::Impostor::PostError) do
      assert im.new_topic(f=1,s=nil,m="hello world")
    end
  end

  def test_new_topic_without_message_set_should_raise_exception
    setup_good_fake_web
    im = fake(config)

    im.forum = 2
    im.subject = "hello world"
    im.message = nil

    # message is not set so posting should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.new_topic
    end
    assert_raises(WWW::Impostor::PostError) do
      assert im.new_topic(f=1,s="hello world",m=nil)
    end
  end

  def test_new_topic_not_logged_in_should_raise_exception
    setup_good_fake_web
    FakeWeb.register_uri(@good_login, :method => :post, 
      :response => response(load_page('wwf79-not-logged-in.html')))
    im = fake(config)
    # not logged in so posting should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.new_topic(f=2,s="hello world",m="hello ruby")
    end
  end

  def test_getting_bad_posting_for_new_topic_page_should_raise_exception
    setup_good_fake_web

    FakeWeb.register_uri(@good_topic_form + '?FID=2', :method => :get, 
                         :response => response("not found",404))

    im = fake(config)

    # bad posting page should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.new_topic(f=2,s="hello world",m="hello ruby")
    end
  end

  def test_bad_submit_response_for_new_topic_should_raise_exception
    setup_good_fake_web :new_topic

    FakeWeb.register_uri(@good_posting, :method => :post, 
                         :response => response("not found",404))

    im = fake(config)

    # bad submit response should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.new_topic(f=2,s="hello world",m="hello ruby")
    end
  end

  def test_too_many_posts_for_new_topic_should_raise_throttle_error
    setup_good_fake_web :new_topic

    FakeWeb.register_uri(@good_posting, :method => :post, 
      :response => response(load_page('wwf79-too-many-topics.html')))

    im = fake(config)

    # bad submit response should throw an exception
    assert_raises(WWW::Impostor::ThrottledError) do
      assert im.new_topic(f=2,s="hello world",m="hello ruby")
    end
  end

  def test_new_topic_should_work
    setup_good_fake_web :new_topic

    im = fake(config)

    # bad submit response should throw an exception
    assert_nothing_raised(WWW::Impostor::ImpostorError) do
      assert im.new_topic(f=2,s="hello world",m="hello ruby")
      assert_equal 2, im.forum
      assert_equal 345, im.topic
      assert_equal "hello world", im.subject
      assert_equal "hello ruby", im.message
    end
  end

  private

  def register_good_login
    FakeWeb.register_uri(@good_login, :method => :get, 
                         :response => response(load_page('wwf79-login.html')))
    FakeWeb.register_uri(@good_login + '?FID=0', :method => :post, 
                         :response => response(load_page('wwf79-logged-in.html')))
    FakeWeb.register_uri(@good_login, :method => :post, 
                         :response => response(load_page('wwf79-logged-in.html')))
  end

  def register_good_index
    FakeWeb.register_uri(@good_index, :method => :get, 
                      :response => response(load_page('wwf79-index.html')))
  end

  def register_good_posting(type = :reply)
    # different gets and posts for "reply" and "new_topic" mode
    case type
    when :reply
      FakeWeb.register_uri(@good_reply_form + '?TID=2', :method => :get, 
                         :response => response(load_page('wwf79-forum_posts.html')))
      FakeWeb.register_uri(@good_posting, :method => :post, 
                         :response => response(load_page('wwf79-good-post-forum_posts.html')))
    when :new_topic
      FakeWeb.register_uri(@good_topic_form + '?FID=2', :method => :get, 
                         :response => response(load_page('wwf79-new-topic-post_message_form.html')))
      FakeWeb.register_uri(@good_posting, :method => :post, 
                         :response => response(load_page('wwf79-new-topic-forum_posts-response.html')))
    else
      raise "unknown type parameter"
    end
  end

  def setup_good_fake_web(type = :reply)
    register_good_index
    register_good_login
    register_good_posting type
  end

  def response(body, code=200)
    res = FakeResponse.new
    res.code = code
    res['Content-Type'] ||= 'text/html'
    res.body = body
    res
  end
=end
end
