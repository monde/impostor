class WWW::Impostor::Post

  attr_reader :auth

  ##
  # Post is initialized with the config and auth of the impostor

  def initialize(config, auth)
    @config = config
    @auth = auth
  end

  ##
  # post a message to the forum and topic thread
  # post is comprised of the following template methods to allow
  # implementation for specific forum applications
  #
  # * validate_post_input(forum, topic, message)
  # * get_reply_uri(params)
  # * get_reply_page(uri)
  # * get_post_form(page)
  # * set_message(form, message)
  # * post_message(form)
  # * validate_post_result(page)

  def post(forum, topic, message)
    self.validate_post_input(forum, topic, message)
    self.auth.login_with_raises
    uri = self.get_reply_uri(forum, topic, message)
    page = get_reply_page(uri)
    form = get_post_form(page)
    set_message(form, message)
    page = post_message(form)
    validate_post_result(page)

    { :forum => forum,
      :topic => topic,
      :message => "Hello World",
      :result => true }
  end

  def validate_post_input(forum, topic, message)
    raise WWW::Impostor::PostError.new("forum not set") unless forum
    raise WWW::Impostor::PostError.new("topic not set") unless topic
    raise WWW::Impostor::PostError.new("message not set") unless message
    true
  end

  def get_reply_uri(forum, topic, message)
    raise WWW::Impostor::MissingTemplateMethodError.new("get_reply_uri must be implemented")
  end

  def get_reply_page(uri)
    raise WWW::Impostor::MissingTemplateMethodError.new("get_reply_page must be implemented")
  end

  def get_post_form(page)
    raise WWW::Impostor::MissingTemplateMethodError.new("get_post_form must be implemented")
  end

  def set_message(form, message)
    raise WWW::Impostor::MissingTemplateMethodError.new("set_message must be implemented")
  end

  def post_message(form)
    raise WWW::Impostor::MissingTemplateMethodError.new("post_message must be implemented")
  end

  def validate_post_result(page)
    raise WWW::Impostor::MissingTemplateMethodError.new("validate_post_result must be implemented")
  end

end
