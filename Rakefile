# -*- ruby -*-

require 'rubygems'
require 'hoe'
begin
  require 'rcov/rcovtask'
rescue LoadError
end
require 'mechanize'
$LOAD_PATH.unshift 'lib'
require 'impostor'

Hoe.plugin :bundler
Hoe.spec('impostor') do |p|
  p.version = WWW::Impostor::VERSION
  p.rubyforge_name = 'impostor'
  p.author = 'Mike Mondragon'
  p.email = 'mikemondragon@gmail.com'
  p.summary = 'imPOSTor posts messages to non-RESTful forums and blogs'
  p.description = p.paragraphs_of('README.txt', 2..5).join("\n\n")
  p.url = p.paragraphs_of('README.txt', 0).first.split(/\n/)[1..-1]
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.extra_deps << ['nokogiri', '>= 1.4.4']
  p.extra_deps << ['mechanize', '>= 1.0.0']
  p.clean_globs << 'coverage'
end

begin
  Rcov::RcovTask.new do |t|
    t.test_files = FileList['test/test_www_impostor*.rb']
    t.verbose = true
  end
rescue NameError
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test_www_impostor*.rb']
  t.verbose = true
end

# vim: syntax=Ruby
