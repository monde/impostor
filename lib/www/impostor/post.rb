class WWW::Impostor::Post

  def initialize(auth, config)
    @auth = auth
    @config = config
  end

  def post(forum, topic, message)
    {
      :forum => 1,
      :topic => 2,
      :message => message,
      :result => true
    }
  end

end
