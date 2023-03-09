# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "impostor"
  s.version = "1.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mike Mondragon"]
  s.date = "2012-03-02"
  s.description = "imPOSTor posts messages to forums\n\n== FEATURES/PROBLEMS:\n\nMakes automated posts to the following forum applications:\n\n* Web Wiz Forums (WWF) 7.9\n* Web Wiz Forums (WWF) 8.0\n* PHP Bullitin Board (phpBB) 2.2\n* PHP Bullitin Board (phpBB) 3.0"
  s.email = "mikemondragon@gmail.com"
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = [".gitignore", ".rspec", "Gemfile", "Gemfile.lock", "History.txt", "Manifest.txt", "README.txt", "Rakefile", "dev_tools/github.rb", "impostor.gemspec", "lib/impostor.rb", "lib/impostor/auth.rb", "lib/impostor/config.rb", "lib/impostor/errors.rb", "lib/impostor/phpbb2.rb", "lib/impostor/phpbb3.rb", "lib/impostor/post.rb", "lib/impostor/topic.rb", "lib/impostor/wwf79.rb", "lib/impostor/wwf80.rb", "spec/auth_spec.rb", "spec/base_spec_helper.rb", "spec/caged_net_http.rb", "spec/config_spec.rb", "spec/fixtures/junk.html", "spec/fixtures/phpbb2-get-new_topic-form-good-response.html", "spec/fixtures/phpbb2-get-viewtopic-for-new-topic-good-response.html", "spec/fixtures/phpbb2-get-viewtopic-for-new-topic-malformed-response.html", "spec/fixtures/phpbb2-index.html", "spec/fixtures/phpbb2-logged-in.html", "spec/fixtures/phpbb2-login.html", "spec/fixtures/phpbb2-not-logged-in.html", "spec/fixtures/phpbb2-post-new_topic-good-response.html", "spec/fixtures/phpbb2-post-reply-good-response.html", "spec/fixtures/phpbb2-post-reply-throttled-response.html", "spec/fixtures/phpbb2-too-many-posts.html", "spec/fixtures/phpbb3-get-new-topic-form-good-response.html", "spec/fixtures/phpbb3-get-reply-form-good-response.html", "spec/fixtures/phpbb3-logged-in.html", "spec/fixtures/phpbb3-login.html", "spec/fixtures/phpbb3-not-logged-in.html", "spec/fixtures/phpbb3-post-new_topic-good-response.html", "spec/fixtures/phpbb3-post-reply-good-response.html", "spec/fixtures/vcr_cassettes/phpbb2-should-be-overlimit-creating-topic.yml", "spec/fixtures/vcr_cassettes/phpbb2-should-create-topic.yml", "spec/fixtures/vcr_cassettes/phpbb2-should-login.yml", "spec/fixtures/vcr_cassettes/phpbb2-should-not-create-new-topic.yml", "spec/fixtures/vcr_cassettes/phpbb2-should-not-login.yml", "spec/fixtures/vcr_cassettes/phpbb2-should-not-post.yml", "spec/fixtures/vcr_cassettes/phpbb2-should-overlimit-error-post.yml", "spec/fixtures/vcr_cassettes/phpbb2-should-post.yml", "spec/fixtures/vcr_cassettes/phpbb3-should-be-overlimit-creating-topic.yml", "spec/fixtures/vcr_cassettes/phpbb3-should-create-topic.yml", "spec/fixtures/vcr_cassettes/phpbb3-should-login.yml", "spec/fixtures/vcr_cassettes/phpbb3-should-not-create-new-topic.yml", "spec/fixtures/vcr_cassettes/phpbb3-should-not-login.yml", "spec/fixtures/vcr_cassettes/phpbb3-should-not-post.yml", "spec/fixtures/vcr_cassettes/phpbb3-should-overlimit-error-post.yml", "spec/fixtures/vcr_cassettes/phpbb3-should-post.yml", "spec/fixtures/wwf79-forum_posts.html", "spec/fixtures/wwf79-general-new-topic-error.html", "spec/fixtures/wwf79-general-posting-error.html", "spec/fixtures/wwf79-good-post-forum_posts.html", "spec/fixtures/wwf79-index.html", "spec/fixtures/wwf79-logged-in.html", "spec/fixtures/wwf79-login.html", "spec/fixtures/wwf79-new-topic-forum_posts-response.html", "spec/fixtures/wwf79-new-topic-post_message_form.html", "spec/fixtures/wwf79-not-logged-in.html", "spec/fixtures/wwf79-too-many-posts.html", "spec/fixtures/wwf79-too-many-topics.html", "spec/fixtures/wwf80-general-posting-error.html", "spec/fixtures/wwf80-get-new_topic-form-good-response.html", "spec/fixtures/wwf80-get-viewtopic-for-new-topic-good-response.html", "spec/fixtures/wwf80-index.html", "spec/fixtures/wwf80-logged-in.html", "spec/fixtures/wwf80-login.html", "spec/fixtures/wwf80-new_reply_form.html", "spec/fixtures/wwf80-not-logged-in.html", "spec/fixtures/wwf80-post-new_topic-good-response.html", "spec/fixtures/wwf80-post-reply-good-response.html", "spec/fixtures/wwf80-too-many-posts.html", "spec/impostor_spec_helper.rb", "spec/integration/phpbb2_spec.rb", "spec/integration/phpbb3_spec.rb", "spec/integration_spec_helper.rb", "spec/phpbb2_spec.rb", "spec/phpbb3_spec.rb", "spec/post_spec.rb", "spec/spec_helper.rb", "spec/test_impostor.rb", "spec/topic_spec.rb", "spec/wwf79_spec.rb", "spec/wwf80_spec.rb", ".gemtest"]
  s.homepage = "https://github.com/monde/impostor"
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "impostor"
  s.rubygems_version = "1.8.10"
  s.summary = "imPOSTor posts messages to non-RESTful forums and blogs"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, ">= 1.4", "< 1.15")
      s.add_runtime_dependency(%q<mechanize>, ["~> 2.5.0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.10"])
      s.add_development_dependency(%q<hoe>, ["~> 2.14"])
      s.add_development_dependency(%q<vcr>)
    else
      s.add_dependency(%q<nokogiri>, ">= 1.4", "< 1.15")
      s.add_dependency(%q<mechanize>, ["~> 2.5.0"])
      s.add_dependency(%q<rdoc>, ["~> 3.10"])
      s.add_dependency(%q<hoe>, ["~> 2.14"])
    end
  else
    s.add_dependency(%q<nokogiri>, ">= 1.4", "< 1.15")
    s.add_dependency(%q<mechanize>, ["~> 2.5.0"])
    s.add_dependency(%q<rdoc>, ["~> 3.10"])
    s.add_dependency(%q<hoe>, ["~> 2.14"])
  end
end
