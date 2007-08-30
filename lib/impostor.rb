require 'impostor/phpbb2'
#require 'impostor/wwf'

module WWW

  ##
  # imPOSTor posts messages to non-RESTful forums and blogs
  #
  # == Example
  #  require 'rubygems'
  #  require 'impostor'
  #  
  #  # config has class :impostor_type => WWW::Impostor::SomeKind
  #  post = WWW::Impostor.create(YAML.load_file('config.yml'))
  #  # or initialize a concrete impostor
  #  post = WWW::Impostor::Phpbb2.new(YAML.load_file('config.yml'))
  #  message = %s{hello world is to application
  #  programmers as tea pots are to graphics programmers}
  #  # your application store forum and topic ids
  #  post.post(forum=5,topic=10,message)
  #  post.logout

  class Impostor

    ##
    # Gem version of Impostor

    VERSION = '0.0.1'

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
    # An error for impostor when a topic id
    # can't be found based on a name/title

    class TopicError < ImpostorError; end

    ##
    # Pass in a config hash to initialize
 
    def initialize(config={})
      @config = config
      load_topics
    end

    ##
    # Instantiate a specific impostor based on its symbol name

    def self.create(config={})
      config = config
      clz = config[:impostor_type]
      clz.new(config)
    end
  
    ##
    # Access the current config

    attr_reader :config

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
      cache = @config[:topics_cache] ||= ""
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
      cache = @config[:topics_cache] ||= ""
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
      @config[:app_root]
    end

=begin
end of the basic interface methods

helpers based on config
=end
#    protected

    ##
    # Get the topics cache

    def topics_cache
      @config[:topics_cache]
    end
  
    ##
    # Get the login page for the application
  
    def login_page
      URI.join(app_root, @config[:login_page])
    end

    ##
    # Get the posting page for the application
  
    def posting_page
      URI.join(app_root, @config[:posting_page])
    end
  
    ##
    # Get the username for the application
  
    def username 
      @config[:username]
    end
  
    ##
    # Get the password for the application
  
    def password 
      @config[:password]
    end

    def user_agent
      @config[:user_agent]
    end
  
    ##
    # is a yaml file for WWW::Mechanize::CookieJar

    def cookie_jar
      @config[:cookie_jar]
    end
  end
end
