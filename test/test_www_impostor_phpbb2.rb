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

module FakeWeb
  class << self
    alias :original_registered_uri? :registered_uri?
  end

  def FakeWeb.registered_uri?(uri, method)
    registered = self.original_registered_uri?(uri, method)
    unless registered
      puts "FakeWeb UNREGISTERED METHOD: #{method}, URI: #{uri}"
    end
    registered
  end
end

class WWW::Impostor::Phpbb2Test < Test::Unit::TestCase
  include Impostor::TestHelper

  class WWW::Impostor::FakePhpbb2 < WWW::Impostor::Phpbb2
    def fake_loggedin=(loggedin)
      @loggedin = loggedin
    end
  end

  def fake(config = {})
    WWW::Impostor::FakePhpbb2.new(config)
  end

  def setup
    FakeWeb.clean_registry()
  end

  # these tests could be refactored to be less procedural, but resist
  # that tempation so that the mechanics of the library and its tests
  # are clear

  def test_should_login
    index = 'http://localhost/phpbb2/'
    login = 'http://localhost/phpbb2/login.php'
    FakeWeb.register_uri(index, :method => :get, :response => response(load_page('phpbb2-index.html')))
    FakeWeb.register_uri(login, :method => :get, :response => response(load_page('phpbb2-login.html')))
    FakeWeb.register_uri(login, :method => :post, :response => response(load_page('phpbb2-logged-in.html')))
    im = WWW::Impostor::Phpbb2.new(config(cookies=false))
    assert_equal true, im.login
    im.logout
  end

  def test_version
    im = WWW::Impostor::Phpbb2.new(config(cookies=false))
    assert im.version
  end

  def test_bad_login_page_should_raise_exception
    login = 'http://localhost/phpbb2/login.php'
    FakeWeb.register_uri(login, :method => :get, :response => response("not found",404))

    im = WWW::Impostor::Phpbb2.new(config(cookies=false))

    assert_raises(WWW::Impostor::LoginError) do
      assert im.new_topic(f=1,s="hello world",m="hello world")
    end
  end

  def test_bad_login_post_should_raise_exception
    index = 'http://localhost/phpbb2/'
    login = 'http://localhost/phpbb2/login.php'
    FakeWeb.register_uri(index, :method => :get, :response => response(load_page('phpbb2-index.html')))
    FakeWeb.register_uri(login, :method => :get, :response => response(load_page('phpbb2-login.html')))
    login = 'http://localhost/phpbb2/login.php'
    FakeWeb.register_uri(login, :method => :post, :response => response("not found",404))

    im = WWW::Impostor::Phpbb2.new(config(cookies=false))

    assert_raises(WWW::Impostor::LoginError) do
      assert im.new_topic(f=1,s="hello world",m="hello world")
    end
  end

  def test_posting_without_message_set_should_raise_exception
    setup_good_fake_web
    im = fake(config)
    im.fake_loggedin = true

    im.forum = 2
    im.topic = 2
    # message is not set so posting should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.post
    end
  end

  def test_posting_without_topic_set_should_raise_exception
    setup_good_fake_web
    im = fake(config)
    im.fake_loggedin = true

    im.forum = 2
    im.message = "hello ruby"
    # topic not set so posting should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.post
    end
  end

  def test_posting_not_logged_in_should_raise_exception
    setup_good_fake_web
    im = fake(config)
    im.fake_loggedin = false

    im.forum = 2
    im.topic = 2
    im.message = "hello ruby"
    # not logged in so posting should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.post
    end
  end

  def test_getting_bad_posting_page_should_raise_exception
    setup_good_fake_web

    posting_mode = '?mode=reply&t=2'
    posting = 'http://localhost/phpbb2/posting.php'
    FakeWeb.register_uri(posting + posting_mode, :method => :post, 
                         :response => response("not found",404))

    im = fake(config)
    im.fake_loggedin = false

    im.forum = 2
    im.topic = 2
    im.message = "hello ruby"
    # bad posting page should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.post
    end
  end

=begin
  def test_should_post
    im = WWW::Impostor::Phpbb2.new(config(cookies=false))
    assert_equal true, im.login
    im.forum = 2
    im.topic = 2
    im.message = "#{Time.now} Hello there #{Time.now}"
    assert im.post
  end

  def test_new_topic_should_raise_exceptions_on_bad_input
    # new_topic 02
    im = WWW::Impostor::Phpbb2.new(config(cookies=false))
    assert_raises(WWW::Impostor::PostError) do
      assert im.new_topic(f=1,s=nil,m="hello world")
    end
    assert_raises(WWW::Impostor::PostError) do
      assert im.new_topic(f=1,s="hello world",m=nil)
    end
    assert_raises(WWW::Impostor::PostError) do
      assert im.new_topic(f=nil,s="hello world",m="hello world")
    end
  end

  def test_new_topic_without_message_set_should_raise_exception
    # new_topic 03
    im = WWW::Impostor::Phpbb2.new(config(cookies=false))
    assert true, im.login
    im.forum = 2
    # creating a topic without a message should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.new_topic('hello world')
    end
  end

  def test_new_topic_without_topic_name_set_should_raise_exception
    # new_topic 04
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
    # new_topic 05
    im = WWW::Impostor::Phpbb2.new(config(cookies=false))
    im.forum = 2
    im.message = "hello ruby"
    # not logged in so posting should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.new_topic('hello world')
    end
  end

  def test_new_topic_without_forum_set_should_raise_exception
    # new_topic 06
    im = WWW::Impostor::Phpbb2.new(config(cookies=false))
    assert true, im.login
    im.message = "hello ruby"
    # forum not set should throw an exception
    assert_raises(WWW::Impostor::PostError) do
      assert im.new_topic('hello world')
    end
  end

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

  def test_new_topic_should_work
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

  def setup_good_fake_web
    index = 'http://localhost/phpbb2/'
    login = 'http://localhost/phpbb2/login.php'
    posting_mode = '?mode=reply&t=2'
    posting = 'http://localhost/phpbb2/posting.php'
    FakeWeb.register_uri(index, :method => :get, 
                                :response => response(load_page('phpbb2-index.html')))
    FakeWeb.register_uri(login, :method => :get, 
                                :response => response(load_page('phpbb2-login.html')))
    FakeWeb.register_uri(login, :method => :post, 
                                :response => response(load_page('phpbb2-logged-in.html')))
    FakeWeb.register_uri(posting + posting_mode, :method => :get, 
                                :response => response(load_page('phpbb2-posting-reply.html')))
    FakeWeb.register_uri(posting, :method => :post, 
                                :response => response(load_page('phpbb2-posting-response.html')))
  end

  def config(cookies=false, config={})
    cookie_jar = File.join(Dir.tmpdir, 'www_impostor_phpbb_test.yml')
    c = {:app_root => 'http://localhost/phpbb2/',
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





  def register_pages
    good_pages = {
=begin
      'http://localhost/phpbb2/' =>
        load_page('phpbb2-index.html'),
      'http://localhost/phpbb2/login.php' =>
        load_page('phpbb2-login.html')
      'http://localhost/phpbb2/POST-login.php' =>
        load_page('phpbb2-logged-in.html'),
      'http://localhost/phpbb2/will-not-login.php' =>
        load_page('phpbb2-will-not-login.html'),
      'http://localhost/phpbb2/POST-will-not-login.php' =>
        load_page('phpbb2-not-logged-in.html'),
      'http://localhost/phpbb2/posting.php?mode=reply&t=2' =>
        load_page('phpbb2-PRE-posting.html'),
      'http://localhost/phpbb2/POST-GOOD-MESSAGE-posting.php' =>
        load_page('phpbb2-good-post-message.html'),
      'http://localhost/phpbb2/posting.php?mode=newtopic&f=2' =>
        load_page('phpbb2-PRE-new-topic.html'),
      'http://localhost/phpbb2/POST-GOOD-NEWTOPIC-posting.php' =>
        load_page('phpbb2-good-post-newtopic.html'),
      'http://localhost/phpbb2/viewtopic.php?p=29' =>
        load_page('phpbb2-good-post-newtopic-follow.html'),
      'http://localhost/phpbb2/bad-login.php' =>
        "",
      'http://localhost/phpbb2/posting-new-topic-with-bad-action.php?mode=newtopic&f=2' =>
        load_page('phpbb2-PRE-new-topic-BAD-ACTION.html'),
      'http://localhost/phpbb2/posting-09A-form.php?mode=newtopic&f=2' =>
        load_page('phpbb2-posting-09A-form.html'),
      'http://localhost/phpbb2/posting-09B-response.php' =>
        load_page('phpbb2-posting-09B-response.html'),
      'http://localhost/phpbb2/viewtopic-09C-response.php?p=29' =>
        load_page('phpbb2-viewtopic-09C-response.html')
=end
    }
    good_pages.each do |url,body|
      res = FakeResponse.new
      res.code = 200
      res['Content-Type'] ||= 'text/html'
      res.body = body
      FakeWeb.register_uri(url, :response => res)
    end

=begin
    error_pages = {
      #'http://localhost/phpbb2/404-posting.php?mode=reply&t=2' =>
      #  "",
      'http://localhost/phpbb2/404-posting.php?mode=newtopic&f=2' =>
        "",
      'http://localhost/phpbb2/POST-BAD-NEWTOPIC-posting.php' =>
        ""
    }

    error_pages.each do |url,body|
      res = FakeResponse.new
      res.code = 404
      res['Content-Type'] ||= 'text/html'
      res.body = body
      FakeWeb.register_uri(url, :response => res)
    end
=end

  end

end
