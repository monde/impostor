Gem::Specification.new do |s|
  s.name = %q{impostor}
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mike Mondragon"]
  s.date = %q{2008-09-24}
  s.description = %q{== FEATURES/PROBLEMS:  Makes automated posts to the following forum applications:  * Web Wiz Forums (WWF) 7.9 * Web Wiz Forums (WWF) 8.0 * PHP Bullitin Board (phpBB) 2.0 (2.0.22) * PHP Bullitin Board (phpBB) 3.0  == SYNOPSIS:}
  s.email = %q{mikemondragon@gmail.com}
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = [".gitignore", "History.txt", "Manifest.txt", "README.txt", "Rakefile", "dev_tools/github.rb", "impostor.gemspec", "lib/impostor.rb", "lib/www/impostor.rb", "lib/www/impostor/phpbb2.rb", "lib/www/impostor/phpbb3.rb", "lib/www/impostor/wwf79.rb", "lib/www/impostor/wwf80.rb", "test/fixtures/phpbb2-get-new_topic-form-good-response.html", "test/fixtures/phpbb2-get-viewtopic-for-new-topic-good-response.html", "test/fixtures/phpbb2-get-viewtopic-for-new-topic-malformed-response.html", "test/fixtures/phpbb2-index.html", "test/fixtures/phpbb2-logged-in.html", "test/fixtures/phpbb2-login.html", "test/fixtures/phpbb2-not-logged-in.html", "test/fixtures/phpbb2-post-new_topic-good-response.html", "test/fixtures/phpbb2-post-reply-good-response.html", "test/fixtures/phpbb2-post-reply-throttled-response.html", "test/fixtures/phpbb2-too-many-posts.html", "test/fixtures/phpbb3-get-new-topic-form-good-response.html", "test/fixtures/phpbb3-get-reply-form-good-response.html", "test/fixtures/phpbb3-logged-in.html", "test/fixtures/phpbb3-login.html", "test/fixtures/phpbb3-not-logged-in.html", "test/fixtures/phpbb3-post-new_topic-good-response.html", "test/fixtures/phpbb3-post-reply-good-response.html", "test/fixtures/wwf79-forum_posts.html", "test/fixtures/wwf79-general-new-topic-error.html", "test/fixtures/wwf79-general-posting-error.html", "test/fixtures/wwf79-good-post-forum_posts.html", "test/fixtures/wwf79-index.html", "test/fixtures/wwf79-logged-in.html", "test/fixtures/wwf79-login.html", "test/fixtures/wwf79-new-topic-forum_posts-response.html", "test/fixtures/wwf79-new-topic-post_message_form.html", "test/fixtures/wwf79-not-logged-in.html", "test/fixtures/wwf79-too-many-posts.html", "test/fixtures/wwf79-too-many-topics.html", "test/fixtures/wwf80-general-posting-error.html", "test/fixtures/wwf80-get-new_topic-form-good-response.html", "test/fixtures/wwf80-get-viewtopic-for-new-topic-good-response.html", "test/fixtures/wwf80-index.html", "test/fixtures/wwf80-logged-in.html", "test/fixtures/wwf80-login.html", "test/fixtures/wwf80-new_reply_form.html", "test/fixtures/wwf80-not-logged-in.html", "test/fixtures/wwf80-post-new_topic-good-response.html", "test/fixtures/wwf80-post-reply-good-response.html", "test/fixtures/wwf80-too-many-posts.html", "test/test_github.rb", "test/test_helper.rb", "test/test_www_impostor.rb", "test/test_www_impostor_phpbb2.rb", "test/test_www_impostor_phpbb3.rb", "test/test_www_impostor_wwf79.rb", "test/test_www_impostor_wwf80.rb", "vendor/plugins/impostor/lib/autotest/discover.rb", "vendor/plugins/impostor/lib/autotest/impostor.rb"]
  s.test_files = ["test/test_www_impostor_phpbb2.rb", "test/test_www_impostor_phpbb3.rb", "test/test_www_impostor_wwf79.rb", "test/test_www_impostor_wwf80.rb", "test/test_github.rb", "test/test_helper.rb", "test/test_www_impostor.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<hpricot>, [">= 0.5.0"])
      s.add_runtime_dependency(%q<mechanize>, [">= 0.7.0"])
      s.add_development_dependency(%q<hoe>, [">= 1.7.0"])
    else
      s.add_dependency(%q<hpricot>, [">= 0.5.0"])
      s.add_dependency(%q<mechanize>, [">= 0.7.0"])
      s.add_dependency(%q<hoe>, [">= 1.7.0"])
    end
  else
    s.add_dependency(%q<hpricot>, [">= 0.5.0"])
    s.add_dependency(%q<mechanize>, [">= 0.7.0"])
    s.add_dependency(%q<hoe>, [">= 1.7.0"])
  end
end
