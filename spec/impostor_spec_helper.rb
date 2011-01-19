module ImpostorSpecHelper

  def sample_phpbb3_config_params
    { :type => :phpbb3,
      :app_root => 'http://example.com/forum/',
      :login_page => 'ucp.php?mode=login',
      :posting_page => 'posting.php',
      :user_agent => 'Windows IE 7',
      :username => 'tester',
      :password => 'pass' }
  end

  def sample_phpbb2_config_params
    { :type => :phpbb2,
      :app_root => 'http://example.com/forum/',
      :login_page => 'login.php',
      :posting_page => 'posting.php',
      :user_agent => 'Windows IE 7',
      :username => 'tester',
      :password => 'pass' }
  end

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

  def sample_wwf79_config_params
    { :type => :wwf79,
      :app_root => 'http://example.com/forum/',
      :login_page => 'login_user.asp',
      :forum_posts_page => 'forum_posts.asp',
      :post_message_page => 'post_message_form.asp',
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

  def wwf80_auth
    config = self.config(sample_wwf80_config_params)
    auth = self.auth(config)
    auth
  end

  def phpbb3_auth
    config = self.config(sample_phpbb3_config_params)
    auth = self.auth(config)
    auth
  end

  def wwf79_auth
    config = self.config(sample_wwf79_config_params)
    auth = self.auth(config)
    auth
  end

  def phpbb2_auth
    config = self.config(sample_phpbb2_config_params)
    auth = self.auth(config)
    auth
  end

  def wwf80_post
    config = self.config(sample_wwf80_config_params)
    auth = self.auth(config)
    self.post(config, auth)
  end

  def impostor(config = {})
    Impostor.new(sample_config_params.merge(config))
  end

  def config(config = {})
    Impostor::Config.new(sample_config_params.merge(config))
  end

  def auth(config = nil)
    config ||= self.config
    auth = Impostor::Auth.new(config)
    auth
  end

  def post(config = nil, auth = nil)
    config ||= self.config
    auth ||= self.auth
    post = Impostor::Post.new(config, auth)
    post
  end

  def topic(config = nil, auth = nil)
    config ||= self.config
    auth ||= self.auth
    topic = Impostor::Topic.new(config, auth)
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
