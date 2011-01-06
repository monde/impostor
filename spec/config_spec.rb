require File.join(File.dirname(__FILE__), 'spec_helper')

describe "impostor's configuration" do

  it "should have an expected set of keys" do
    lambda { config }.should_not raise_error(WWW::Impostor::ConfigError)
    expected = [:type, :username, :password, :app_root, :login_page]
    expected.each do |key|
      config = { :type => :test,
            :username => "user",
            :password => "pass",
            :app_root => "http://example.com",
            :login_page => "/login"
      }
      config.delete(key)
      lambda {
        WWW::Impostor::Config.new(config)
      }.should raise_error(WWW::Impostor::ConfigError)
    end
  end

  it "should key off symbols or strings" do
    config = config(:foo => "bar")
    config.config(:foo).should == "bar"
    config.config("foo").should == "bar"
  end

  it "should set up an agent" do
    config.agent.should respond_to(:get)
  end

  it "should load a topics cache persisted in a file" do
    cache = Tempfile.new('foo')
    topics = {"1" => {"2" => "Hello World"}}
    cache.write(topics.to_yaml)
    cache.close

    YAML.should_receive(:load_file).with(cache.path).and_return(topics)
    config(:topics_cache => cache.path).topics.should == topics
  end

  it "should load a topics cache persisted in memory" do
    YAML.should_not_receive(:load_file)
    config.topics.should == {}
  end

  it "should add a subject" do
    c = config
    c.topics.should == {}
    c.add_subject(1, 2, "Hello World")
    c.topics.should == {"1" => {"2" => "Hello World"}}
  end

  it "should get a subject" do
    c = config
    c.add_subject(1, 2, "Hello World")
    c.topics.should == {"1" => {"2" => "Hello World"}}
    c.get_subject(1, 2).should == "Hello World"
  end

  it "should save topics"

  it "should have an app root" do
    config(:app_root => "http://example.com").app_root.
      should == "http://example.com"
  end

  it "should have a topics cache config entry"

  it "should have a username"

  it "should have a password"

  it "should have a user agent"

  it "should have a cookie jar"

end
