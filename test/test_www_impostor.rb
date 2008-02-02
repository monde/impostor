require File.join(File.dirname(__FILE__), "..", "lib", "impostor")
require File.join(File.dirname(__FILE__), "test_helper")

require 'tempfile'
require 'test/unit'

class WWW::ImpostorTest < Test::Unit::TestCase

  def test_impostor_error
    message = 'test message'
    error = WWW::Impostor::ImpostorError.new(StandardError.new(message))
    assert error
    assert_equal message, error.original_exception.message
  end

  def test_create_should_return_an_instance
    im = WWW::Impostor.create({:impostor_type => "WWW::Impostor::Fake"})
    assert_equal WWW::Impostor::Fake, im.class 
    im = WWW::Impostor.create({:impostor_type => WWW::Impostor::Fake})
    assert_equal WWW::Impostor::Fake, im.class 
  end

  def test_add_subject_should_work
    im = WWW::Impostor.create({:impostor_type => "WWW::Impostor::Fake"})
    im.add_subject(f=10,t=10,s="hello world")
    assert_equal s, im.get_subject(f,t)
    im.add_subject(f=10,t=11,s="hello world2")
    assert_equal s, im.get_subject(f,t)
  end

  def test_config_should_not_be_nil
    assert_nothing_raised(StandardError) do
      impostor = fake(Hash.new)
      assert impostor.config
    end
  end

  def test_login_page_should_be_clean
    impostor = fake({:app_root => 'http://localhost/', :login_page => '/foo/bar'})
    assert_equal 'http://localhost/foo/bar', impostor.test_helper_login_page.to_s
  end

  def test_load_topics_should_do_so
    # setup a temp file
    topics_file = Tempfile.new('test_load_topics')

    # make some topics
    topics_path = topics_file.path
    topics_file.close
    forum = 7
    topic = 5
    topics = {forum => { topic => 'my topic title'}}
    #
    # dump the topics out
    File.open(topics_path, 'w') do |out|
      YAML.dump(topics, out)
    end

    # make an impostor and ensure the topics are correct
    impostor = fake({:topics_cache => topics_file.path})
    assert_equal 'my topic title', impostor.get_subject(forum, topic)
    assert_equal nil, impostor.get_subject(82, 101)

    #dump the test file
    topics_file.unlink
  end

  def test_topics_should_save_and_load
    # setup a temp file
    topics_file = Tempfile.new('test_load_topics')

    # make some topics
    topics_path = topics_file.path
    topics_file.close
    forum_one = 7
    topic_one = 5
    topics = {forum_one => { topic_one => 'my topic title'}}

    # dump the topics out
    File.open(topics_path, 'w') do |out|
      YAML.dump(topics, out)
    end

    # make an impostor, add a topic, save
    forum_two = 8
    topic_two = 22
    impostor = fake({:topics_cache => topics_file.path})
    impostor.test_helper_add_topic(forum_one, topic_two, 'hello world')
    impostor.test_helper_add_topic(forum_two, topic_two, 'foo bar')

    impostor.save_topics

    # get a new impostor and make sure the topics were saved
    impostor = fake({:topics_cache => topics_file.path})
    assert_equal 'my topic title', impostor.get_subject(forum_one, topic_one)
    assert_equal 'hello world', impostor.get_subject(forum_one, topic_two)
    assert_equal 'foo bar', impostor.get_subject(forum_two, topic_two)
    assert_equal nil, impostor.get_subject(82, 101)

    # test topics_cache
    assert_equal topics_file.path, impostor.test_helper_topics_cache

    #dump the test file
    topics_file.unlink
  end

  def test_get_subject_should_return_something_when_forum_and_topic_are_set

    # setup a temp file
    topics_file = Tempfile.new('test_load_topics')

    # make some topics
    topics_path = topics_file.path
    topics_file.close
    forum = 7
    topic = 5
    topics = {forum => { topic => 'my topic title'}}
    #
    # dump the topics out
    File.open(topics_path, 'w') do |out|
      YAML.dump(topics, out)
    end

    # make an impostor and ensure the topic name is correct
    impostor = fake({:topics_cache => topics_file.path})
    impostor.forum = forum
    impostor.topic = topic
    assert_equal 'my topic title', impostor.get_subject

    #clean up
    topics_file.unlink
  end

  private

  class WWW::Impostor::Fake < WWW::Impostor
    def test_helper_login_page
      login_page
    end

    def test_helper_posting_page
      posting_page
    end

    def test_helper_topics_cache
      topics_cache
    end

    def test_helper_add_topic(f,t,n)
      @topics[f].nil? ? @topics[f] = {t => n} : @topics[f][t] = n
    end
  end

  def fake(config = {})
    WWW::Impostor::Fake.new(config)
  end
end
