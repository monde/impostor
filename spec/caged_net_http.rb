# monkey patch Net::HTTP so un caged requests don't go over the wire
module Net #:nodoc:
  class HTTP #:nodoc:
    alias :old_net_http_request :request
    alias :old_net_http_connect :connect

    def request(req, body = nil, &block)
      # prot = use_ssl ? "https" : "http"
      # uri_cls = use_ssl ? URI::HTTPS : URI::HTTP
      uri_cls = URI::HTTP
      query = req.path.split('?',2)
      opts = {:host => self.address,
             :port => self.port, :path => query[0]}
      opts[:query] = query[1] if query[1]
      uri = uri_cls.build(opts)
      if uri.to_s =~ /^http:\/\/localhost\//
        old_net_http_request(req, body, &block)
      else
        raise ArgumentError.new("#{req.method} method to #{uri} not being handled in testing")
      end
    end

    def connect
      if address.to_s == "localhost"
        old_net_http_connect
      end
    end

  end
end
