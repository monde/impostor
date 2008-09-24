require 'rubygems'
Dir.glob(File.join(File.dirname(__FILE__), 'impostor/*.rb')).each {|f| require f }

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

    class << self #:nodoc:
      alias orig_new new
      def new(conf)
        klass = WWW::Impostor.create(conf)
        klass.orig_new(conf)
      end
    end

    ##
    # Gem version of Impostor

    VERSION = '0.2.1'

    ##
    # An application error

    class ImpostorError < RuntimeError

      ##
      # The original exception

      attr_accessor :original_exception

      ##
      # Creates a new ImpostorError with +message+ and +original_exception+

      def initialize(e)
        exception = e.class == String ? StandardError.new(e) : e
        @original_exception = exception
        message = "Impostor error: #{exception.message} (#{exception.class})"
        super message
      end

    end

    ##
    # An error for impostor login failure

    class LoginError < ImpostorError; end

    ##
    # An error for impostor post failure

    class PostError < ImpostorError; end

    ##
    # An error for impostor when a topic id can't be found based on a 
    # name/title.

    class TopicError < ImpostorError; end

    ##
    # An error for impostor when the receiving forum rejects the post due to 
    # a throttling or spam error but which the user can re-attempt at a later
    # time.

    class ThrottledError < ImpostorError; end

    ##
    # Pass in a config hash to initialize
 
    def initialize(conf={})
      @config = conf
      load_topics
    end

    ##
    # Instantiate a specific impostor based on its symbol name

    def self.create(conf={})
      type = conf[:type] || conf[:type.to_s]
      clz = type.is_a?(Class) ? type : eval("WWW::Impostor::#{type.to_s.capitalize}")
      clz
    end
  
    ##
    # Access the current config and key it without regard for symbols or strings

    def config(*key)
      return @config if key.empty?
      @config[key.first.to_sym] || @config[key.first.to_s]
    end

    ##
    # Get/set the application version that impostor is interfacing with
  
    attr_accessor :version
  
    ##
    # Login to the forum, returns true if logged in, false otherwise
  
    def login; end

    ##
    # Log out of the forum, true if logged in, false otherwise
  
    def logout; end

    ##
    # Load the topics that the impostor already knows about

    def load_topics
      cache = config[:topics_cache] ||= ""
      if File::exist?(cache)
        @topics = YAML::load_file(cache)
      else
        @topics = Hash.new
      end
    end

    ##
    # Add subject to topics hash

    def add_subject(forum,topic,name)
      if @topics[forum].nil?
        @topics[forum] = {topic, name}
      else
        @topics[forum][topic] = name
      end
    end

    ##
    # Save the topics

    def save_topics
      cache = config[:topics_cache] ||= ""
      if File::exist?(cache) 
        File.open(cache, 'w') do |out|
          YAML.dump(@topics, out)
        end
      end
    end
  
    ##
    # Post the message
  
    def post(forum = @forum, topic = @topic, message = @message); end
  
    ##
    #  get/set the current message
  
    attr_accessor :message

    ##
    #  get/set the current subject
  
    attr_accessor :subject
  
    ##
    # Get/set the form id
  
    attr_accessor :forum
  
    ##
    # Get/set the topic id

    attr_accessor :topic

    ##
    # Get the topic name (subject) based on forum and topic ids

    def get_subject(forum = @forum, topic = @topic)
      if @topics && @topics[forum]
        return @topics[forum][topic]
      end
      nil
    end

    ##
    # Make a new topic

    def new_topic(forum=@forum, subject=@subject, message=@message); end
   
    ##
    # Gets the application root of the application such as
    # http://example.com/phpbb or http://example.com/forums
  
    def app_root 
      config[:app_root]
    end

    protected

    ##
    # Get the topics cache

    def topics_cache
      config[:topics_cache]
    end
  
    ##
    # Get the login page for the application
  
    def login_page
      URI.join(app_root, config[:login_page])
    end

    ##
    # Get the username for the application
  
    def username 
      config[:username]
    end
  
    ##
    # Get the password for the application
  
    def password 
      config[:password]
    end

    ##
    # A Mechanize user agent name, see the mechanize documentation
    # 'Linux Mozilla', 'Mac Safari', 'Windows IE 7', etc.

    def user_agent
      config[:user_agent]
    end
  
    ##
    # is a yaml file for WWW::Mechanize::CookieJar

    def cookie_jar
      config[:cookie_jar]
    end
  end
end
