require File.join(File.dirname(__FILE__), "..", "lib", "impostor")

require 'test/unit'
require 'mocha'

# monkey patch Net::HTTP so un caged requests don't go over the wire
module Net #:nodoc:
  class HTTP #:nodoc:
    alias :old_net_http_request :request
    alias :old_net_http_connect :connect

    def request(req, body = nil, &block)
      prot = use_ssl ? "https" : "http"
      uri_cls = use_ssl ? URI::HTTPS : URI::HTTP
      query = req.path.split('?',2)
      opts = {:host => self.address,
             :port => self.port, :path => query[0]}
      opts[:query] = query[1] if query[1]
      uri = uri_cls.build(opts)
      raise ArgumentError.new("#{req.method} method to #{uri} not being handled in testing")
    end

    def connect
    end

  end
end

module TestHelper

  ##
  # helps load pages

  def load_page(file)
    IO.readlines("#{File.dirname(__FILE__)}/fixtures/#{file}")
  end

end
