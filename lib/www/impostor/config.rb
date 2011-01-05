class WWW::Impostor::Config

  def initialize(config)
    # FIXME should we just deep symbolize the config keys?
    @config = config
    setup_agent
    load_topics
  end

  ##
  # Access the current config and key it without regard for symbols or strings

  def config(key)
    # FIXME should we just deep symbolize the config keys?
    @config[key.to_sym] || @config[key.to_s]
  end

  def setup_agent
    @agent = Mechanize.new
    @agent.user_agent_alias = self.user_agent if self.user_agent
    # jar is a yaml file
    @agent.cookie_jar.load(cookie_jar) if cookie_jar && File.exist?(cookie_jar)
    @loggedin = false
  end

  ##
  # Load the topics that the impostor already knows about

  def load_topics
    cache = self.config(:topics_cache) || ""
    if File::exist?(cache)
      @topics = YAML::load_file(cache)
    else
      @topics = Hash.new
    end
  end

  ##
  # Add subject to topics hash

  def add_subject(forum, topic, name)
    if @topics[forum].nil?
      @topics[forum] = {topic, name}
    else
      @topics[forum][topic] = name
    end
  end

  ##
  # Get the topic name (subject) based on forum and topic ids

  def get_subject(forum, topic)
    if @topics && @topics[forum]
      return @topics[forum][topic]
    end
    nil
  end

  ##
  # Save the topics

  def save_topics
    cache = self.config(:topics_cache) || ""
    if File::exist?(cache)
      File.open(cache, 'w') do |out|
        YAML.dump(@topics, out)
      end
    end
  end

  ##
  # Get the topic name (subject) based on forum and topic ids

  def get_subject(forum, topic)
    @config.get_subject(forum, topic)
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
    self.config(:user_agent)
  end

  ##
  # is a yaml file for WWW::Mechanize::CookieJar

  def cookie_jar
    self.config(:cookie_jar)
  end

end

