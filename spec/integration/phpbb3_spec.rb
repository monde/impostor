require File.join(File.dirname(__FILE__), '..', 'integration_spec_helper')

describe "a phpbb3 impostor" do

  it "should login" do
    VCR.use_cassette('phpbb3-should-login', :record => :new_episodes) do
      conf = self.sample_phpbb3_config_params(
        :app_root => 'http://localhost/forum/'
      )
      config = Impostor::Config.new(conf)
      auth = Impostor::Auth.new(config)
      auth.login.should be_true
    end
  end

  it "should fail login" do
    VCR.use_cassette('phpbb3-should-not-login', :record => :new_episodes) do
      conf = self.sample_phpbb3_config_params(
        :app_root => 'http://localhost/forum/',
        :password => 'junk'
      )
      config = Impostor::Config.new(conf)
      auth = Impostor::Auth.new(config)
      auth.login.should_not be_true
    end
  end

  it "should post a message" do
    VCR.use_cassette('phpbb3-should-post', :record => :new_episodes) do
      conf = self.sample_phpbb3_config_params(
        :app_root => 'http://localhost/forum/',
        :sleep_before_post => 1
      )
      impostor = Impostor.new(conf)
      impostor.post(forum=2, topic=3, message='Hello World').should == {
        :forum => 2, :topic => 3, :post => 10, :message => "Hello World", :result => true
      }
    end
  end

  it "should fail posting a message" do
    pending
  end

  it "should fail posting a message because of over limit" do
    pending
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

