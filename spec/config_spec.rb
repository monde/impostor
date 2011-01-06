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

  it "should use tempfile for topics cache when it's not config'd"

  it "should use tempfile for topics cache when it's not config'd"

  it "should load topics"

  it "should add a subject"

  it "should get a subject"

  it "should save topics"

  it "should have an app root" do
    config(:app_root => "http://example.com").app_root.
      should == "http://example.com"
  end

  it "should get the topics cache"

  it "should have a topics cache"

  it "should have a username"

  it "should have a password"

  it "should have a user agent"

  it "should have a cookie jar"

end
