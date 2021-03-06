require File.join(File.dirname(__FILE__), 'spec_helper')

describe "impostor's configuration" do

  it "should have an expected set of keys" do
    lambda { config }.should_not raise_error(Impostor::ConfigError)
    expected = [:type, :username, :password, :app_root, :login_page]
    expected.each do |key|
      config = { :type => :test,
            :username => "user",
            :password => "password",
            :app_root => "http://example.com",
            :login_page => "/login"
      }
      config.delete(key)
      lambda {
        Impostor::Config.new(config)
      }.should raise_error(Impostor::ConfigError)
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

  it "should save topics when it has a file to persist to" do
    cache = Tempfile.new('foo')
    topics = {"1" => {"2" => "Hello World"}}
    cache.write(topics.to_yaml)
    cache.close

    c = config(:topics_cache => cache.path)
    c.add_subject(1, 3, "Foo Bar")
    c.save_topics

    YAML::load_file(cache.path).should ==
      {"1" => {"2" => "Hello World", "3" => "Foo Bar"}}
  end

  it "should have an app root" do
    config(:app_root => "http://example.com").app_root.
      should == "http://example.com"
  end

  it "should have a topics cache config entry" do
    config(:topics_cache => "/hello/world").topics_cache.should == "/hello/world"
  end

  it "should have a username" do
    config.username.should == "user"
  end

  it "should have a password" do
    config.password.should == "password"
  end

  it "should have a default user agent" do
    config.user_agent.should == "Mechanize"
  end

  it "should have a default user agent" do
    config(:user_agent => "Linux Mozilla").user_agent.should == "Linux Mozilla"
  end

  it "should have a cookie jar" do
    config(:cookie_jar => "/hello/world").cookie_jar.should == "/hello/world"
  end

  it "should have zero for sleep setting" do
    config.sleep_before_post.should be_zero
  end

  it "should have for sleep setting" do
    config(:sleep_before_post => 1).sleep_before_post.should == 1
  end

  it "should have a logger" do
    log_file = Tempfile.new('log')
    self.config(:logger => log_file.path).agent.log.
      instance_variable_get(:@logdev).filename.should == log_file.path
  end

  it "should have a cookie jar" do
    jar_file = Tempfile.new('cookies')
    jar_file.write({}.to_yaml)
    jar_file.close

    config = self.config(:cookie_jar => jar_file.path)
    config.agent.cookie_jar.should_receive(:save_as).with(jar_file.path).once

    config.save_cookie_jar
  end

  it "should have a type" do
    config(:type => :foo).type.should == :foo
  end

end
