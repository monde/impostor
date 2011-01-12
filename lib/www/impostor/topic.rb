class WWW::Impostor::Topic

  attr_reader :auth

  ##
  # Topic is initialized with the auth of the impostor

  def initialize(auth)
    @auth = auth
  end

  ##
  # create a new topic in the forum with the subject title and initial message
  #
  # * validate_new_topic_input(forum, subject, message)
  # * get_new_topic_uri(params)
  # * get_new_topic_page(uri)
  # * get_post_form(page)
  # * set_subject_and_message(form, subject, message)
  # * post_new_topic(form)
  # * validate_post_result(page)

  def new_topic(forum, subject, message)
    self.validate_topic_input(forum, subject, message)
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
