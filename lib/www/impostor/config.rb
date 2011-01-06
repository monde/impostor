class WWW::Impostor::Config

  attr_reader :agent
  attr_reader :topics

  def initialize(config)
    @config = config
    validate_keys(:type, :username, :password, :app_root, :login_page)
    setup_agent
    load_topics
  end

  ##
  # Validates expected keys are in the config

  def validate_keys(*keys)
    keys.each do |key|
      val = self.config(key)
      raise WWW::Impostor::ConfigError.new("Missing key '#{key}' in configuration") unless val
    end
  end

  ##
  # Access the current config and key it without regard for symbols or strings

  def config(key)
    @config[key.to_sym] || @config[key.to_s]
  end

  ##
  # Sets up the mechanize agent initialized with cookie jar file specified by
  # the :cookie_jar configuration parameter if it exists

  def setup_agent
    @agent = Mechanize.new
    @agent.user_agent_alias = self.user_agent if self.user_agent
    # jar is a yaml file
    @agent.cookie_jar.load(cookie_jar) if cookie_jar && File.exist?(cookie_jar)
  end

  ##
  # Load the topics that the impostor already knows about

  def load_topics
    cache = self.topics_cache || ""
    if File::exist?(cache)
      @topics = YAML::load_file(cache)
    else
      @topics = Hash.new
    end
  end

  ##
  # Add subject to topics hash

  def add_subject(forum, topic, name)
    forum = forum.to_s
    topic = topic.to_s
    if self.topics[forum].nil?
      self.topics[forum] = {topic, name}
    else
      self.topics[forum][topic] = name
    end
  end

  ##
  # Get the topic name (subject) based on forum and topic ids

  def get_subject(forum, topic)
    forum = forum.to_s
    topic = topic.to_s
    self.topics[forum] ? self.topics[forum][topic] : nil
  end

  ##
  # Save the topics

  def save_topics
    cache = self.topics_cache || ""
    if File::exist?(cache)
      File.open(cache, 'w') do |out|
        YAML.dump(self.topics, out)
      end
    end
  end

  ##
  # Gets the application root of the application such as
  # http://example.com/phpbb or http://example.com/forums

  def app_root
    self.config(:app_root)
  end

  ##
  # Get the topics cache

  def topics_cache
    self.config(:topics_cache)
  end

  ##
  # Get the login page for the application

  def login_page
    URI.join(app_root, self.config(:login_page))
  end

  ##
  # Get the username for the application

  def username
    self.config(:username)
  end

  ##
  # Get the password for the application

  def password
    self.config(:password)
  end

  ##
  # A Mechanize user agent name, see the mechanize documentation
  # 'Linux Mozilla', 'Mac Safari', 'Windows IE 7', etc.

  def user_agent
    self.config(:user_agent) || 'Mechanize'
  end

  ##
  # is a yaml file for WWW::Mechanize::CookieJar

  def cookie_jar
    self.config(:cookie_jar)
  end

end

