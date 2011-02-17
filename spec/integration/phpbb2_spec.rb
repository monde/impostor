require File.join(File.dirname(__FILE__), '..', 'integration_spec_helper')

describe "a phpbb2 impostor" do

  it "should login" do
    VCR.use_cassette('phpbb2-should-login', :record => :new_episodes) do
      conf = self.sample_phpbb2_config_params(
        :app_root => 'http://localhost/phpbb2/',
        :sleep_before_post => 1
      )
      config = Impostor::Config.new(conf)
      auth = Impostor::Auth.new(config)
      auth.login.should be_true
    end
  end

  it "should fail login" do
    VCR.use_cassette('phpbb2-should-not-login', :record => :new_episodes) do
      conf = self.sample_phpbb2_config_params(
        :app_root => 'http://localhost/phpbb2/',
        :sleep_before_post => 1,
        :password => 'junk'
      )
      config = Impostor::Config.new(conf)
      auth = Impostor::Auth.new(config)
      auth.login.should_not be_true
    end
  end

  it "should post a message" do
    VCR.use_cassette('phpbb2-should-post', :record => :new_episodes) do
      conf = self.sample_phpbb2_config_params(
        :app_root => 'http://localhost/phpbb2/',
        :sleep_before_post => 1
      )
      impostor = Impostor.new(conf)
      impostor.post(forum=1, topic=2, message='Hello World').should == {
        :forum => 1, :topic => 2, :post => 6, :message => "Hello World", :result => true
      }
    end
  end

  it "should fail posting a message" do
    VCR.use_cassette('phpbb2-should-not-post', :record => :new_episodes) do
      conf = self.sample_phpbb2_config_params(
        :app_root => 'http://localhost/phpbb2/',
        :sleep_before_post => 1
      )
      impostor = Impostor.new(conf)
      lambda {
        impostor.post(forum=99, topic=99, message='Hello World')
      }.should raise_error( Impostor::PostError )
    end
  end

  it "should fail posting a message because of over limit" do
    VCR.use_cassette('phpbb2-should-overlimit-error-post', :record => :new_episodes) do
      conf = self.sample_phpbb2_config_params(
        :app_root => 'http://localhost/phpbb2/',
        :sleep_before_post => 1
      )
      impostor = Impostor.new(conf)
      lambda {
        impostor.post(forum=1, topic=2, message='one')
        impostor.post(forum=1, topic=2, message='two')
      }.should raise_error( Impostor::ThrottledError )
    end
  end

  it "should create a new topic and message" do
    pending
  end

  it "should fail creating a topic" do
    pending
  end

  it "should fail create topic because of over limit" do
    pending
  end

end

