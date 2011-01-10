class WWW::Impostor::Post

  ##
  # Post is initialized with the config and auth of the impostor

  def initialize(config, auth)
    @auth = auth
    @config = config
  end

  ##
  # post a message to the forum and topic thread
  # post is comprised of the following template methods to allow
  # implementation for specific forum applications
  #
  # * validate_post_input(forum, topic, message)
  # * new_reply_uri(params)
  # * get_reply_page(uri)
  # * validate_post_form(page)
  # * set_message(page, message)
  # * post_message(form, button)
  # * validate_post_result(page)

  def post(forum, topic, message)
    validate_post_input(forum, topic, message)
  end

  def validate_post_input(forum, topic, message)
    raise WWW::Impostor::PostError.new("forum not set") unless forum
    raise WWW::Impostor::PostError.new("topic not set") unless topic
    raise WWW::Impostor::PostError.new("message not set") unless message
    true
  end

end
