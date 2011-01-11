module ImpostorSpecHelper

  def impostor(config = {})
    c = { :type => :test }
    WWW::Impostor.new(c.merge(config))
  end

  def config(config = {})
    c = { :type => :test,
          :username => "user",
          :password => "pass",
          :app_root => "http://example.com",
          :login_page => "/login"
    }

    WWW::Impostor::Config.new(c.merge(config))
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

end
