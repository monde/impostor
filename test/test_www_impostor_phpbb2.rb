# test helper loads all the required libraries for testing
# with fake web
require File.dirname(__FILE__) + "/test_helper"

require 'test/unit'

class WWW::Impostor::Phpbb2Test < Test::Unit::TestCase
  include Impostor::TestHelper

  def fake(config = {})
    WWW::Impostor::FakePhpbb2.new(config)
  end

  def setup
    FakeWeb.clean_registry()
    @good_index = 'http://localhost/phpbb2/'
    @good_login = 'http://localhost/phpbb2/login.php'
    @good_posting = 'http://localhost/phpbb2/posting.php'
  end

  class WWW::Impostor::FakePhpbb2 < WWW::Impostor::Phpbb2
    def fake_loggedin=(loggedin)
      @loggedin = loggedin
    end

    def test_fetch_login_page
        fetch_login_page
    end
  end

  def test_version
    im = WWW::Impostor::Phpbb2.new(config(cookies=false))
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

    im = WWW::Impostor::Phpbb2.new(config(cookies=false))

    assert_raises(WWW::Impostor::LoginError) do
      im.login
    end
  end

  def test_bad_login_post_should_raise_exception
    register_good_index
    FakeWeb.register_uri(@good_login, :method => :get, 
                         :response => response(load_page('phpbb2-login.html')))
    FakeWeb.register_uri(@good_login, :method => :post, 
                         :response => response("not found",404))

    im = WWW::Impostor::Phpbb2.new(config(cookies=false))

    assert_raises(WWW::Impostor::LoginError) do
      im.login
    end
  end

  def test_should_login
    register_good_index
    register_good_login
    im = WWW::Impostor::Phpbb2.new(config(cookies=false))
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
    FakeWeb.register_uri(@good_login, :method => :post, 
      :response => response(load_page('phpbb2-not-logged-in.html')))
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

    FakeWeb.register_uri(@good_posting + '?mode=reply&t=2', :method => :get, 
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

    FakeWeb.register_uri(@good_posting, :method => :post, 
                         :response => response("not found",404))

    im = fake(config)

    # bad submit should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.post(f=2,t=2,m="hello ruby")
    end
  end

  def test_too_many_posts_for_post_should_raise_exception
    setup_good_fake_web

    posting = 'http://localhost/phpbb2/posting.php'
    FakeWeb.register_uri(@good_posting, :method => :post, 
      :response => response(load_page('phpbb2-too-many-posts.html')))

    im = fake(config)

    im.forum = 2
    im.topic = 2
    im.message = "hello ruby"
    # bad posting page should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.post
    end
  end

  def test_getting_unknown_posting_response_should_return_false
    setup_good_fake_web

    FakeWeb.register_uri(@good_posting, :method => :post, 
                         :response => response("junk response",200))

    im = fake(config)

    im.forum = 2
    im.topic = 2
    im.message = "hello ruby"
    assert_equal false, im.post
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
      :response => response(load_page('phpbb2-not-logged-in.html')))
    im = fake(config)
    # not logged in so posting should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.new_topic(f=2,s="hello world",m="hello ruby")
    end
  end

  def test_getting_bad_posting_for_new_topic_page_should_raise_exception
    setup_good_fake_web

    FakeWeb.register_uri(@good_posting + 'mode=newtopic&f=2', :method => :get, 
                         :response => response("not found",404))

    im = fake(config)

    # bad posting page should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.new_topic(f=2,s="hello world",m="hello ruby")
    end
  end

  def test_bad_submit_response_for_new_topic_should_raise_exception
    setup_good_fake_web :reply

    FakeWeb.register_uri(@good_posting, :method => :post, 
                         :response => response("not found",404))

    im = fake(config)

    # bad submit response should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.new_topic(f=2,s="hello world",m="hello ruby")
    end
  end

=begin

  def test_new_topic_with_form_error_should_raise_exception
    # new_topic 07
    im = WWW::Impostor::Phpbb2.new(
           config(cookies=false,options={:posting_page=>'404-posting.php'}))
    assert_raises(WWW::Impostor::PostError) do
      assert_equal true, im.new_topic(forum=2,subject="s",message="m")
    end
  end

  def test_new_topic_with_bad_form_action_should_raise_exception
    # new_topic 08
    im = WWW::Impostor::Phpbb2.new(
           config(cookies=false,options={:posting_page=>'posting-new-topic-with-bad-action.php'}))
    assert_raises(WWW::Impostor::PostError) do
      assert_equal true, im.new_topic(forum=2,subject="s",message="m")
    end
  end

  def test_new_topic_with_bad_final_response_should_raise_exception
    # new_topic 09
    im = WWW::Impostor::Phpbb2.new(
           config(cookies=false,options={:posting_page=>'posting-09A-form.php?mode=newtopic&f=2'}))
    assert_raises(WWW::Impostor::PostError) do
      assert_equal true, im.new_topic(forum=2,subject="s",message="m")
    end
  end


=end

# save these for end so that rcov covers the code incrementally
# as we write tests
=begin
  def test_new_topic_should_create_topic_with_post
    # new_topic 10
    im = WWW::Impostor::Phpbb2.new(config(cookies=false))
    forum = 2
    subject = "hello world"
    message = "hello ruby"
    assert_nothing_raised(WWW::Impostor::ImpostorError) do
      assert_equal true, im.new_topic(forum,subject,message)
    end
    assert_equal forum, im.forum
    assert_equal subject, im.subject
    assert_equal message, im.message
  end
=end


  private

    def register_good_login
      FakeWeb.register_uri(@good_login, :method => :get, 
                           :response => response(load_page('phpbb2-login.html')))
      FakeWeb.register_uri(@good_login, :method => :post, 
                           :response => response(load_page('phpbb2-logged-in.html')))
    end

    def register_good_index
      FakeWeb.register_uri(@good_index, :method => :get, 
                        :response => response(load_page('phpbb2-index.html')))
    end

  def register_good_posting(type = :reply)
    # different gets and posts for "reply" and "new_topic" mode
    case type
    when :reply
      FakeWeb.register_uri(@good_posting + '?mode=reply&t=2', :method => :get, 
                         :response => response(load_page('phpbb2-get-new_topic-form-good-response.html')))
      FakeWeb.register_uri(@good_posting, :method => :post, 
                         :response => response(load_page('phpbb2-post-reply-good-response.html')))
    when :new_topic
      FakeWeb.register_uri(@good_posting, :method => :post, 
                         :response => response(load_page('phpbb2-get-new_topic-form-good-response.html')))
      FakeWeb.register_uri(@good_posting, :method => :post, 
                         :response => response(load_page('phpbb2-post-new_topic-good-response.html')))
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
    cookie_jar = File.join(Dir.tmpdir, 'www_impostor_phpbb_test.yml')
    c = {:app_root => @good_index,
      :login_page => 'login.php', 
      :posting_page => 'posting.php', 
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
