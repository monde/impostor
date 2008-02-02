impostor
    by Mike Mondragon
    http://impostor.rubyforge.org/

== DESCRIPTION:
  
imPOSTor posts messages to forums

== FEATURES/PROBLEMS:

Makes automatic posts to the following forum applications:

* Web Wiz Forums (WWF) 7.9
* Web Wiz Forums (WWF) 8.0
* PHP Bullitin Board (phpBB) 2.0 (2.0.22)

== SYNOPSIS:

# config yaml has options specefic to wwf79, wwf80, phpbb2, etc.
# read the impostor docs for options to the kind of forum in use
# config can be keyed by symbols or strings
config = YAML::load_file('conf/impostor.yml')
post = WWW::Impostor.new(config)
message = %q{hello world is to application
programmers as tea pots are to graphics programmers}
# your application stores forum and topic ids
post.post(forum=5,topic=10,message)
# make a new topic
subject = "about programmers..."
post.new_topic(forum=7,subject,message)
post.logout

== REQUIREMENTS:

* mechanize
* hpricot

== INSTALL:

* sudo gem install impostor

== LICENSE:

(The MIT License)

Copyright (c) 2008 Mike Mondragon

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
