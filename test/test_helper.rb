require 'net/http'

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
