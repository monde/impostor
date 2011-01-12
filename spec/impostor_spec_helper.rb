module ImpostorSpecHelper

  def sample_config_params
    { :type => :test,
      :username => "user",
      :password => "pass",
      :app_root => "http://example.com",
      :login_page => "/login" }
  end

  def impostor(config = {})
    WWW::Impostor.new(config.merge(sample_config_params))
  end

  def config(config = {})
    WWW::Impostor::Config.new(config.merge(sample_config_params))
  end

  def auth(config = nil)
    config ||= self.config
    auth = WWW::Impostor::Auth.new(config)
    auth.extend eval("WWW::Impostor::#{config.config(:type).to_s.capitalize}::Auth")
    auth
  end

  def post(auth = nil)
    auth ||= self.auth
    post = WWW::Impostor::Post.new(auth)
    post.extend eval("WWW::Impostor::#{config.config(:type).to_s.capitalize}::Post")
    post
  end

  def topic(config = nil, auth = nil)
    config ||= self.config
    auth ||= self.auth
    topic = WWW::Impostor::Topic.new(config, auth)
    topic.extend eval("WWW::Impostor::#{config.config(:type).to_s.capitalize}::Topic")
    topic
  end

end
