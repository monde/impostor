$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require File.dirname(__FILE__) + "/test_helper"

require 'test/unit'
require 'rubygems'
require 'hpricot'
require 'fake_web'
require 'open-uri'
require 'impostor'
require 'yaml'
require 'pp'

class WWW::Impostor::Phpbb2Test < Test::Unit::TestCase
  include Impostor::TestHelper

  def setup
    res = FakeResponse.new
    res.code = 200
    res['Content-Type'] ||= 'text/html'
    res.body = load_page('phpbb2-index-not-loggedin.html')
    FakeWeb.register_uri('http://localhost/phpbb2/', :response => res)

    res = FakeResponse.new
    res.code = 200
    res['Content-Type'] ||= 'text/html'
    res.body = load_page('phpbb2-login.html')
    FakeWeb.register_uri('http://localhost/phpbb2/login.php', :response => res)

    res = FakeResponse.new
    res.code = 200
    res['Content-Type'] ||= 'text/html'
    res.body = load_page('phpbb2-logged-in.html')
    FakeWeb.register_uri('http://localhost/phpbb2/POST-login.php', :response => res)

    res = FakeResponse.new
    res.code = 200
    res['Content-Type'] ||= 'text/html'
    res.body = load_page('phpbb2-PRE-posting.html')
    FakeWeb.register_uri('http://localhost/phpbb2/posting.php?mode=reply&t=2', :response => res)

    res = FakeResponse.new
    res.code = 200
    res['Content-Type'] ||= 'text/html'
    res.body = load_page('phpbb2-good-post-message.html')
    FakeWeb.register_uri('http://localhost/phpbb2/POST-GOOD-MESSAGE-posting.php', :response => res)

    res = FakeResponse.new
    res.code = 200
    res['Content-Type'] ||= 'text/html'
    res.body = load_page('phpbb2-PRE-new-topic.html')
    FakeWeb.register_uri('http://localhost/phpbb2/posting.php?mode=newtopic&f=2', :response => res)

    res = FakeResponse.new
    res.code = 200
    res['Content-Type'] ||= 'text/html'
    res.body = load_page('phpbb2-good-post-newtopic.html')
    FakeWeb.register_uri('http://localhost/phpbb2/POST-GOOD-NEWTOPIC-posting.php', :response => res)

    res = FakeResponse.new
    res.code = 200
    res['Content-Type'] ||= 'text/html'
    res.body = load_page('phpbb2-good-post-newtopic-follow.html')
    FakeWeb.register_uri('http://localhost/phpbb2/viewtopic.php?p=29#29', :response => res)
  end

  def test_should_login
    im = WWW::Impostor::Phpbb2.new(config(cookies=false))
    assert_equal true, im.login
    im.logout
  end

  def test_posting_without_message_set_should_raise_exception
    im = WWW::Impostor::Phpbb2.new(config(cookies=false))
    assert_equal true, im.login
    im.forum = 2
    im.topic = 2
    # message is not set so posting should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.post
    end
  end

  def test_posting_without_topic_set_should_raise_exception
    im = WWW::Impostor::Phpbb2.new(config(cookies=false))
    assert_equal true, im.login
    im.forum = 2
    im.message = "hello ruby"
    # topic not set so posting should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.post
    end
  end

  def test_should_post
    im = WWW::Impostor::Phpbb2.new(config(cookies=false))
    assert_equal true, im.login
    im.forum = 2
    im.topic = 2
    im.message = "#{Time.now} Hello there #{Time.now}"
    assert im.post
  end

  def test_new_topic_without_message_set_should_raise_exception
    im = WWW::Impostor::Phpbb2.new(config(cookies=false))
    assert true, im.login
    im.forum = 2
    # creating a topic without a message should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.new_topic('hello world')
    end
  end

  def test_new_topic_without_topic_name_set_should_raise_exception
    im = WWW::Impostor::Phpbb2.new(config(cookies=false))
    assert true, im.login
    im.forum = 2
    im.message = "hello ruby"
    # creating a nil named topic should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.new_topic(nil)
    end
  end

  def test_new_topic_not_logged_in_should_raise_exception
    im = WWW::Impostor::Phpbb2.new(config(cookies=false))
    im.forum = 2
    im.message = "hello ruby"
    # not logged in so posting should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.new_topic('hello world')
    end
  end

  def test_new_topic_without_forum_set_should_raise_exception
    im = WWW::Impostor::Phpbb2.new(config(cookies=false))
    assert true, im.login
    im.message = "hello ruby"
    # forum not set should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.new_topic('hello world')
    end
  end

  def config(cookies=false)
    cookie_jar = File.join(Dir.tmpdir, 'www_impostor_phpbb_test.yml')
    config = {:app_root => 'http://localhost/phpbb2/',
     :login_page => 'login.php', 
     :posting_page => 'posting.php', 
     :user_agent => 'Windows IE 7', 
     :username => 'tester',
     :password => 'test'}

     config[:cookie_jar] = cookie_jar if cookies

     config
  end
end
