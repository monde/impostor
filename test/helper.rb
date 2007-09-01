$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

# we need to load net/http, then our monkey patch of Net::HTTP, then 
# fake_web in that order
require 'net/http'
require 'net/https'
require 'impostor'

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
      raise ArgumentError.new("#{req.method} method to #{uri} not being handled by FakeWeb")
    end

    def connect
    end

  end
end

require 'rubygems'
require 'fake_web'

module Impostor
  module TestHelper

    ##
    # helps load pages

    def load_page(file)
      IO.readlines("#{File.dirname(__FILE__)}/fixtures/#{file}")
    end

  end
end

class FakeResponse < Net::HTTPResponse
  include Net::HTTPHeader

  attr_reader :code
  attr_accessor :body, :query, :cookies

  def code=(c)
    @code = c.to_s
  end

  alias :status :code
  alias :status= :code=

  def initialize
    @header = {}
    @body = ''
    @code = nil
    @query = nil
    @cookies = []
  end

  def read_body
    yield body
  end
end

