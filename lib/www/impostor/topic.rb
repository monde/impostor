class WWW::Impostor::Topic

  def initialize(auth, config)
    @auth = auth
    @config = config
  end

  ##
  # Make a new topic

  def new_topic(forum, subject, message)
    #       _new_topic_validate_input(forum, subject, message)
    #uri  = _new_topic_form_query(forum)
    #page = _new_topic_get_topic_form(uri)
    #form = _new_topic_validate_topic_form(page)
    #form = _new_topic_set_subject_and_message(form, subject, message)

    {
      :forum => 1,
      :subject => subject,
      :message => message,
      :result => true
    }
  end

  #def _new_topic_set_subject_and_message(form, subject, message)
  #  raise 'not implemented'
  #end

  #def _new_topic_validate_topic_form(page)
  #  raise 'not implemented'
  #end

  #def _new_topic_get_topic_form(uri)
  #  # get the submit form
  #  begin
  #    page = @agent.get(uri)
  #  rescue StandardError => err
  #    raise PostError.new(err)
  #  end
  #end

  #def _new_topic_form_query(forum)
  #  raise 'not implemented'
  #end

  #def _new_topic_validate_input(forum, subject, message)
  #  raise PostError.new("forum not set") unless forum
  #  raise PostError.new("topic name not given") unless subject
  #  raise PostError.new("message not set") unless message

  #  login
  #  raise PostError.new("not logged in") unless @loggedin
  #end
end
