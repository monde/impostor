%W{ mechanize nokogiri cgi }.each do |g|
  begin
    require g
  rescue LoadError
    require 'rubygems'
    require g
  end
end
require 'logger'

class Impostor

  ##
  # imPOSTor posts messages to non-RESTful forums and blogs
  #
  # == Example
  #  require 'rubygems'
  #  require 'impostor'
  #
  #  # config yaml has options specefic to wwf79, wwf80, phpbb2, etc.
  #  # read the impostor docs for options to the kind of forum in use
  #  # config can be keyed by symbols or strings
  #  post = Impostor.new(YAML.load_file('config.yml'))
  #  message = %q!hello world is to application
  #  programmers as tea pots are to graphics programmers!
  #  # your application store forum and topic ids
  #  post.post(forum=5,topic=10,message)
  #  # make a new topic
  #  subject = "about programmers..."
  #  post.new_topic(forum=7,subject,message)
  #
  #  keys and values that can be set in the impostor configuration
  #
  #  :type              - kind of imPOSTor, :phpbb2, :wwf79, :wwf80, etc.
  #  :username          - forum username
  #  :password          - forum password
  #  :topics_cache      - cache of forum topics
  #  :user_agent        - Mechanize browser user-agent
  #  :cookie_jar        - saved cookies from Mechanize browser
  #  :app_root          - url to forum
  #  :login_page        - forum login page
  #  :logger            - A logger object or path ot a logger file.
  #  :sleep_before_post - Number of seconds delay before posting to forum
  #
  #  See documentation for each type of imPOSTor for additional configuration
  #  parameters that are needed for the specific kind of imPOSTor.  A sample
  #  configuration is provided in the documentation for each.


  ##
  # Gem version of Impostor

  VERSION = '1.3.2'

  ##
  # Pass in a config hash to initialize

  def initialize(config={})
    @config = Config.new(config)
    @auth   = Auth.new(@config)
    @post   = Post.new(@config, @auth)
    @topic  = Topic.new(@config, @auth)

    type = @config.type
    raise ConfigError.new("Missing 'type' key in configuration") unless type

    extend eval("Impostor::#{type.to_s.capitalize}")
  end

  ##
  # our version

  def version
    VERSION
  end

  ##
  # Post the message

  def post(forum, topic, message)
    @post.post(forum, topic, message)
  end

  ##
  # Make a new topic

  def new_topic(forum, subject, message)
    @topic.new_topic(forum, subject, message)
  end

  ##
  # Login

  def login
    @auth.login
  end

  def self.not_tested(who, what)
    warn <<WARNMSG
!!!!! IMPLEMENTATION WARNING !!!!!
#{who}##{what} did not have real integration test data to work against in the
refactoring of Impostor from version 0.2.1 to 1.0.0.  Please contact the author
to help supply live data allowing real integration tests for this method.
WARNMSG
  end

end

Dir.glob(File.join(File.dirname(__FILE__), 'impostor/**/*.rb')).each {|f| require f }
