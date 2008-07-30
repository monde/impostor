impostor
    by Mike Mondragon
    http://impostor.rubyforge.org/

== DESCRIPTION:
  
imPOSTor posts messages to forums

== FEATURES/PROBLEMS:

Makes automated posts to the following forum applications:

* Web Wiz Forums (WWF) 7.9
* Web Wiz Forums (WWF) 8.0
* PHP Bullitin Board (phpBB) 2.0 (2.0.22)
* PHP Bullitin Board (phpBB) 3.0

== SYNOPSIS:

# config yaml has options specific to wwf79, phpbb2, etc.
# Read the impostor docs for configuration options for the kind of forum to 
# be accessed.
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

== SOURCE

git clone git://github.com/monde/impostor.git
svn co svn://rubyforge.org/var/svn/impostor/trunk impostor

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
