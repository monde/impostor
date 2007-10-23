# test helper loads all the required libraries for testing
# with fake web
require File.dirname(__FILE__) + "/helper"

require 'test/unit'

class WWW::Impostor::Wwf80Test < Test::Unit::TestCase
  include Impostor::TestHelper

  def fake(config = {})
    WWW::Impostor::FakeWwf80.new(config)
  end

  def setup
    FakeWeb.clean_registry()
    @good_index = 'http://localhost/wwf80/'
    @good_login = 'http://localhost/wwf80/login_user.asp'
    @good_reply_form = 'http://localhost/wwf80/new_reply_form.asp'
    @good_topic_form = 'http://localhost/wwf80/new_topic_form.asp'
    @good_posting = 'http://localhost/wwf80/new_post.asp?PN='
    @good_viewtopic = 'http://localhost/wwf80/forum_posts.asp'
  end

  class WWW::Impostor::FakeWwf80 < WWW::Impostor::Wwf80
    def fake_loggedin=(loggedin)
      @loggedin = loggedin
    end

    def test_fetch_login_page
        fetch_login_page
    end
  end

  def test_version
    im = WWW::Impostor::Wwf80.new(config(cookies=false))
    assert im.version
  end

  def test_fetch_login_page
    register_good_index
    register_good_login
    page = fake(config).test_fetch_login_page 
    assert page
  end

  def test_bad_login_page_should_raise_exception
    FakeWeb.register_uri(@good_login, :method => :get, 
                         :response => response("not found",404))

    im = WWW::Impostor::Wwf80.new(config(cookies=false))

    assert_raises(WWW::Impostor::LoginError) do
      im.login
    end
  end

  def test_bad_login_post_should_raise_exception
    register_good_index
    FakeWeb.register_uri(@good_login, :method => :get, 
                         :response => response(load_page('wwf80-login.html')))
    FakeWeb.register_uri(@good_login, :method => :post, 
                         :response => response("not found",404))

    im = WWW::Impostor::Wwf80.new(config(cookies=false))

    assert_raises(WWW::Impostor::LoginError) do
      im.login
    end
  end

  def test_should_login
    register_good_index
    register_good_login
    im = WWW::Impostor::Wwf80.new(config(cookies=false))
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
      :response => response(load_page('wwf80-not-logged-in.html')))
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

  def test_too_many_posts_for_post_should_raise_exception
    setup_good_fake_web

    FakeWeb.register_uri(@good_posting, :method => :post, 
      :response => response(load_page('wwf80-too-many-posts.html')))

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
      :response => response(load_page('wwf80-not-logged-in.html')))
    im = fake(config)
    # not logged in so posting should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.new_topic(f=2,s="hello world",m="hello ruby")
    end
  end

  def test_getting_bad_posting_for_new_topic_page_should_raise_exception
    setup_good_fake_web

    FakeWeb.register_uri(@good_reply_form + 'mode=newtopic&f=2', :method => :get, 
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

  def test_new_topic_should_work
    setup_good_fake_web :new_topic

    im = fake(config)

    # bad submit response should throw an exception
    assert_nothing_raised(WWW::Impostor::ImpostorError) do
      assert im.new_topic(f=2,s="hello world",m="hello ruby")
      assert_equal 2, im.forum
      assert_equal "hello world", im.subject
      assert_equal "hello ruby", im.message
    end
  end

  private

  def register_good_login
    FakeWeb.register_uri(@good_login, :method => :get, 
                         :response => response(load_page('wwf80-login.html')))
    FakeWeb.register_uri(@good_login + '?FID=0', :method => :post, 
                         :response => response(load_page('wwf80-logged-in.html')))
    FakeWeb.register_uri(@good_login, :method => :post, 
                         :response => response(load_page('wwf80-logged-in.html')))
  end

  def register_good_index
    FakeWeb.register_uri(@good_index, :method => :get, 
                      :response => response(load_page('wwf80-index.html')))
  end

  def register_good_posting(type = :reply)
    # different gets and posts for "reply" and "new_topic" mode
    case type
    when :reply
      FakeWeb.register_uri(@good_reply_form + '?TID=2', :method => :get, 
                         :response => response(load_page('wwf80-new_reply_form.html')))
      FakeWeb.register_uri(@good_posting, :method => :post, 
                         :response => response(load_page('wwf80-post-reply-good-response.html')))
    when :new_topic
      FakeWeb.register_uri(@good_topic_form + '?FID=2', :method => :get, 
                         :response => response(load_page('wwf80-get-new_topic-form-good-response.html')))
      FakeWeb.register_uri(@good_posting, :method => :post, 
                         :response => response(load_page('wwf80-post-new_topic-good-response.html')))
      #FakeWeb.register_uri(@good_viewtopic + '?p=60', :method => :get, 
      #                   :response => response(load_page('wwf80-get-viewtopic-for-new-topic-good-response.html')))
    else
      raise "unknown type parameter"
    end
  end

  def setup_good_fake_web(type = :reply)
    register_good_index
    register_good_login
    register_good_posting type
  end

  def config(cookies=false, config={})
    cookie_jar = File.join(Dir.tmpdir, 'www_impostor_wwf80_test.yml')
    c = {:app_root => @good_index,
      :login_page => 'login_user.asp', 
      :new_reply_page => 'new_reply_form.asp', 
      :new_topic_page => 'new_topic_form.asp', 
      :user_agent => 'Windows IE 7', 
      :username => 'tester',
      :password => 'test'}.merge(config)

    c[:cookie_jar] = cookie_jar if cookies
    c
  end

  def response(body, code=200)
    res = FakeResponse.new
    res.code = code
    res['Content-Type'] ||= 'text/html'
    res.body = body
    res
  end
end
