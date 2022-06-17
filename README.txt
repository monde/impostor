impostor
    by Mike Mondragon
    https://github.com/monde/impostor
    http://impostor.rubyforge.org/

== DESCRIPTION:

imPOSTor posts messages to forums

== FEATURES/PROBLEMS:

Makes automated posts to the following forum applications:

* Web Wiz Forums (WWF) 7.9
* Web Wiz Forums (WWF) 8.0
* PHP Bullitin Board (phpBB) 2.2
* PHP Bullitin Board (phpBB) 3.0

== SYNOPSIS:

# config yaml has options specific to wwf79, phpbb2, etc.
# Read the impostor docs for configuration options for the kind of forum to
# be accessed.
# config can be keyed by symbols or strings
config = YAML::load_file('conf/impostor.yml')
impostor = Impostor.new(config)
message = %q{hello world is to application
programmers as tea pots are to graphics programmers}
# your application stores forum and topic ids
impostor.post(forum=5,topic=10,message)
# make a new topic
subject = "about programmers..."
impostor.new_topic(forum=7,subject,message)


== CONFIGURATION

Configurable options:

* :app_root
* :cookie_jar
* :follow_meta_refresh
* :forum_posts_page
* :logger
* :login_page
* :new_reply_page
* :new_topic_page
* :password
* :post_message_page
* :posting_page
* :sleep_before_post
* :topics_cache
* :type
* :user_agent
* :username

Example

config = {
 :app_root=>"http://example.com/phpBB/",
 :login_page=>"login.php",
 :password=>"pass",
 :posting_page=>"posting.php",
 :sleep_before_post=>2,
 :type=>:phpbb2,
 :user_agent=>"Windows IE 7",
 :username=>"user",
}
impostor = Impostor.new(config)

== REQUIREMENTS:

* hoe
* mechanize
* nokogiri

== SOURCE

git clone git://github.com/monde/impostor.git

== INSTALL:

* gem install impostor

== LICENSE:

(The MIT License)

Copyright (c) 2008-2011 Mike Mondragon

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.




