module WWW
  class Impostor

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
    # An for misconfiguration

    class ConfigError < ImpostorError; end

  end
end