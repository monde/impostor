%W{ mechanize nokogiri cgi }.each do |g|
  begin
    require g
  rescue LoadError
    require 'rubygems'
    require g
  end
end

Dir.glob(File.join(File.dirname(__FILE__), 'impostor/**/*.rb')).each {|f| require f }

module WWW

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
  #  post = WWW::Impostor.new(YAML.load_file('config.yml'))
  #  message = %q!hello world is to application
  #  programmers as tea pots are to graphics programmers!
  #  # your application store forum and topic ids
  #  post.post(forum=5,topic=10,message)
  #  # make a new topic
  #  subject = "about programmers..."
  #  post.new_topic(forum=7,subject,message)
  #  post.logout
  #
  #  keys and values that can be set in the impostor configuration
  #
  #  :type           - kind of imPOSTor, :phpbb2, :wwf79, :wwf80, etc.
  #  :username       - forum username
  #  :password       - forum password
  #  :topics_cache   - cache of forum topics
  #  :user_agent     - Mechanize browser user-agent
  #  :cookie_jar     - saved cookies from Mechanize browser
  #  :app_root       - url to forum
  #  :login_page     - forum login page
  #
  #  See documentation for each type of imPOSTor for additional configuration
  #  parameters that are needed for the specific kind of imPOSTor.  A sample
  #  configuration is provided in the documentation for each.

  class Impostor

    ##
    # Gem version of Impostor

    VERSION = '0.3.0'

    ##
    # Pass in a config hash to initialize

    def initialize(config={})
      @config = Config.new(config)
      @auth   = Auth.new(@config)
      @topic  = Topic.new(@auth, @config)
      @post   = Post.new(@auth, @config)

      type = self.config(:type)
      if type
        extend eval("WWW::Impostor::#{type.to_s.capitalize}")
        @auth.extend eval("WWW::Impostor::#{type.to_s.capitalize}::Auth")
        @topic.extend eval("WWW::Impostor::#{type.to_s.capitalize}::Topic")
        @post.extend eval("WWW::Impostor::#{type.to_s.capitalize}::Post")
      end

    end

    ##
    # Access the current config and key it without regard for symbols or strings

    def config(key)
      @config.config(key)
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

  end
end
