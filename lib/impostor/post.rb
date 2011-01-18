class Impostor::Post

  attr_reader :config
  attr_reader :auth

  ##
  # Post is initialized with the auth of the impostor

  def initialize(config, auth)
    @config = config
    @auth = auth
    self.extend eval("Impostor::#{config.type.to_s.capitalize}::Post")
  end

  ##
  # post a message to the forum and topic thread
  # post is comprised of the following template methods to allow
  # implementation for specific forum applications
  #
  # * validate_post_input(forum, topic, message)
  # * get_reply_uri(forum, topic)
  # * get_reply_page(uri)
  # * get_post_form(page)
  # * set_message(form, message)
  # * post_message(form)
  # * validate_post_result(page)

  def post(forum, topic, message)
    self.validate_post_input(forum, topic, message)
    self.auth.login_with_raises
    uri = self.get_reply_uri(forum, topic)
    page = get_reply_page(uri)
    form = get_post_form(page)
    set_message(form, message)
    page = post_message(form)
    validate_post_result(page)

    { :forum => forum,
      :topic => topic,
      :message => message,
      :result => true }
  end

  ##
  # validate the inputs forum, topic, and message

  def validate_post_input(forum, topic, message)
    raise Impostor::PostError.new("forum not set") unless forum
    raise Impostor::PostError.new("topic not set") unless topic
    raise Impostor::PostError.new("message not set") unless message
    true
  end

  ##
  # return a uri used to fetch the reply page based on the forum, topic, and
  # message

  def get_reply_uri(forum, topic)
    raise Impostor::MissingTemplateMethodError.new("get_reply_uri must be implemented")
  end

  ##
  # return the reply page that is fetched with the reply uri

  def get_reply_page(uri)
    raise Impostor::MissingTemplateMethodError.new("get_reply_page must be implemented")
  end

  ##
  # return the form used for posting a message from the reply page

  def get_post_form(page)
    raise Impostor::MissingTemplateMethodError.new("get_post_form must be implemented")
  end

  ##
  # set the message to reply with on the reply form

  def set_message(form, message)
    raise Impostor::MissingTemplateMethodError.new("set_message must be implemented")
  end

  ##
  # post the message form

  def post_message(form)
    raise Impostor::MissingTemplateMethodError.new("post_message must be implemented")
  end

  ##
  # validate the result of posting the message form

  def validate_post_result(page)
    raise Impostor::MissingTemplateMethodError.new("validate_post_result must be implemented")
  end

end
