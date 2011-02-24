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
  # * get_post_from_result(page)
  #
  # A hash of results is returned, having keys to the :forum, :topic, new :post
  # id, :message, and :result

  def post(forum, topic, message)
    self.validate_post_input(forum, topic, message)
    self.auth.login_with_raises
    uri = self.get_reply_uri(forum, topic)
    page = get_reply_page(uri)
    form = get_post_form(page)
    set_message(form, message)
    page = post_message(form)
    post = get_post_from_result(page)

    { :forum => forum,
      :topic => topic,
      :post => post,
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
    begin
      page = self.config.agent.get(uri)
    rescue StandardError => err
      raise Impostor::PostError.new(err)
    end
  end

  ##
  # return the form used for posting a message from the reply page

  def get_post_form(page)
    raise Impostor::MissingTemplateMethodError.new("get_post_form must be implemented")
  end

  ##
  # set the message to reply with on the reply form

  def set_message(form, message)
    form.message = message
    form
  end

  ##
  # post the message form

  def post_message(form)
    begin
      config.sleep_before_post
      form.submit
    rescue StandardError => err
      raise Impostor::PostError.new(err)
    end
  end

  ##
  # get post id from the result of posting the message form

  def get_post_from_result(page)
    raise Impostor::MissingTemplateMethodError.new("get_post_from_result must be implemented")
  end

end
