class WWW::Impostor::Topic

  attr_reader :config
  attr_reader :auth

  ##
  # Topic is initialized with the auth of the impostor

  def initialize(config, auth)
    @config = config
    @auth = auth
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
    raise WWW::Impostor::TopicError.new("forum not set") unless forum
    raise WWW::Impostor::TopicError.new("subject not set") unless subject
    raise WWW::Impostor::TopicError.new("message not set") unless message
    true
  end

end
