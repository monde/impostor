class Impostor::Topic

  attr_reader :config
  attr_reader :auth

  ##
  # Topic is initialized with the auth of the impostor

  def initialize(config, auth)
    @config = config
    @auth = auth
    self.extend eval("Impostor::#{config.type.to_s.capitalize}::Topic")
  end

  ##
  # create a new topic in the forum with the subject title and initial message
  #
  # * validate_new_topic_input(forum, subject, message)
  # * get_new_topic_uri(forum, subject, message)
  # * get_new_topic_page(uri)
  # * get_new_topic_form(page)
  # * set_subject_and_message(form, subject, message)
  # * post_new_topic(form)
  # * validate_new_topic_result(page)
  # * get_topic_from_result(page)

  def new_topic(forum, subject, message)
    self.validate_topic_input(forum, subject, message)
    self.auth.login_with_raises
    uri = self.get_new_topic_uri(forum, subject, message)
    page = self.get_new_topic_page(uri)
    form = self.get_new_topic_form(page)
    self.set_subject_and_message(form, subject, message)
    page = self.post_new_topic(form)
    self.validate_new_topic_result(page)
    topic = self.get_topic_from_result(page)

    self.config.add_subject(forum, topic, subject)

    { :forum => forum,
      :topic => topic,
      :subject => subject,
      :message => message,
      :result => true }
  end

  ##
  # validate the inputs forum, topic, and message

  def validate_topic_input(forum, subject, message)
    raise Impostor::TopicError.new("forum not set") unless forum
    raise Impostor::TopicError.new("subject not set") unless subject
    raise Impostor::TopicError.new("message not set") unless message
    true
  end

  ##
  # return a uri used to fetch the new topic page based on the forum, subject,
  # and message

  def get_new_topic_uri(forum, subject, message)
    raise Impostor::MissingTemplateMethodError.new("get_new_topic_uri must be implemented")
  end

  ##
  # Get the page that has the form for new topics referenced by the uri

  def get_new_topic_page(uri)
    begin
      self.config.agent.get(uri)
    rescue StandardError => err
      raise Impostor::TopicError.new(err)
    end
  end

  ##
  # Get the the new topic form on the page

  def get_new_topic_form(page)
    raise Impostor::MissingTemplateMethodError.new("get_new_topic_form must be implemented")
  end

  ##
  # Set the subject and message on the new topic form

  def set_subject_and_message(form, subject, message)
    raise Impostor::MissingTemplateMethodError.new("set_subject_and_message must be implemented")
  end

  ##
  # Post the new topic that is contained on the form

  def post_new_topic(form)
    begin
      config.sleep_before_post
      form.submit
    rescue StandardError => err
      raise Impostor::TopicError.new(err)
    end
  end

  ##
  # Validate the result of posting the new topic

  def validate_new_topic_result(page)
    raise Impostor::MissingTemplateMethodError.new("validate_new_topic_result must be implemented")
  end

  ##
  # Get the new topic identifier from the result page

  def get_topic_from_result(page)
    raise Impostor::MissingTemplateMethodError.new("get_topic_from_result must be implemented")
  end
end
