module ImpostorSpecHelper

  def sample_wwf80_config_params
    { :type => :wwf80,
      :app_root => 'http://example.com/forum/',
      :login_page => 'login_user.asp',
      :new_reply_page => 'new_reply_form.asp',
      :new_topic_page => 'new_topic_form.asp',
      :user_agent => 'Windows IE 7',
      :username => 'tester',
      :password => 'pass' }
  end

  def sample_config_params
    { :type => :test,
      :username => "user",
      :password => "pass",
      :app_root => "http://example.com",
      :login_page => "/login" }
  end

  def impostor(config = {})
    WWW::Impostor.new(sample_config_params.merge(config))
  end

  def config(config = {})
    WWW::Impostor::Config.new(sample_config_params.merge(config))
  end

  def auth(config = nil)
    config ||= self.config
    auth = WWW::Impostor::Auth.new(config)
    auth
  end

  def post(config = nil, auth = nil)
    config ||= self.config
    auth ||= self.auth
    post = WWW::Impostor::Post.new(config, auth)
    post
  end

  def topic(config = nil, auth = nil)
    config ||= self.config
    auth ||= self.auth
    topic = WWW::Impostor::Topic.new(config, auth)
    topic
  end

  def load_fixture_page(fixture, uri, code=200, agent=nil)
    uri = URI.parse(uri) if uri.is_a?(String)
    file = File.expand_path("#{File.dirname(__FILE__)}/fixtures/#{fixture}")
    body = open(file).read
    response = {'content-type' => 'text/html'}

    Mechanize::Page.new(uri, response, body, code, agent)
  end

end
