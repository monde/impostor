require File.join(File.dirname(__FILE__), '..', 'integration_spec_helper')

describe "a phpbb3 impostor" do

  it "should login" do
    VCR.use_cassette('phpbb3-should-login', :record => :new_episodes) do
      conf = self.sample_phpbb3_config_params(
        :app_root => 'http://localhost/phpbb3/'
      )
      config = Impostor::Config.new(conf)
      auth = Impostor::Auth.new(config)
      auth.login.should be_true
    end
  end

  it "should fail login" do
    VCR.use_cassette('phpbb3-should-not-login', :record => :new_episodes) do
      conf = self.sample_phpbb3_config_params(
        :app_root => 'http://localhost/phpbb3/',
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
        :app_root => 'http://localhost/phpbb3/',
        :sleep_before_post => 1
      )
      impostor = Impostor.new(conf)
      impostor.post(forum=2, topic=3, message='Hello World Again').should == {
        :forum => 2, :topic => 3, :post => 17, :message => "Hello World Again", :result => true
      }
    end
  end

  it "should fail posting a message" do
    VCR.use_cassette('phpbb3-should-not-post', :record => :new_episodes) do
      conf = self.sample_phpbb3_config_params(
        :app_root => 'http://localhost/phpbb3/',
        :sleep_before_post => 1
      )
      impostor = Impostor.new(conf)
      lambda {
        impostor.post(forum=99, topic=99, message='Hello World')
      }.should raise_error( Impostor::PostError )
    end
  end

  it "should fail posting a message because of over limit" do
    VCR.use_cassette('phpbb3-should-overlimit-error-post', :record => :new_episodes) do
      conf = self.sample_phpbb3_config_params(
        :app_root => 'http://localhost/phpbb3/',
        :sleep_before_post => 1
      )
      impostor = Impostor.new(conf)
      lambda {
        impostor.post(forum=2, topic=3, message='one')
        impostor.post(forum=2, topic=3, message='two')
      }.should raise_error( Impostor::ThrottledError )
    end
  end

  it "should create a new topic and message" do
    VCR.use_cassette('phpbb3-should-create-topic', :record => :new_episodes) do
      conf = self.sample_phpbb3_config_params(
        :app_root => 'http://localhost/phpbb3/',
        :sleep_before_post => 1
      )
      impostor = Impostor.new(conf)
      impostor.new_topic(forum=2, subject='A Special Message', message='Hello World').should == {
        :forum => 2, :topic => 8, :subject => 'A Special Message',  :message => "Hello World", :result => true
      }
    end
  end

  it "should fail creating a topic" do
    VCR.use_cassette('phpbb3-should-not-create-new-topic', :record => :new_episodes) do
      conf = self.sample_phpbb3_config_params(
        :app_root => 'http://localhost/phpbb3/',
        :sleep_before_post => 1
      )
      impostor = Impostor.new(conf)
      lambda {
        impostor.new_topic(forum=99, subject='Break Dance', message='Should not create new topic')
      }.should raise_error( Impostor::TopicError )
    end
  end

  it "should fail create topic because of over limit" do
    VCR.use_cassette('phpbb3-should-be-overlimit-creating-topic', :record => :new_episodes) do
      conf = self.sample_phpbb3_config_params(
        :app_root => 'http://localhost/phpbb3/',
        :sleep_before_post => 1
      )
      impostor = Impostor.new(conf)
      lambda {
        impostor.new_topic(forum=2, subject='First', message='a message')
        impostor.new_topic(forum=2, subject='Second', message='should fail')
      }.should raise_error( Impostor::ThrottledError )
    end
  end

end

