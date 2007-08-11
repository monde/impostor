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

Hoe.new('impostor', WWW::Impostor::VERSION) do |p|
  p.rubyforge_name = 'impostor'
  p.author = 'Mike Mondragon'
  p.email = 'mikemondragon@gmail.com'
  p.summary = 'imPOSTor posts messages to non-RESTful forums and blogs'
  p.description = p.paragraphs_of('README.txt', 2..5).join("\n\n")
  p.url = p.paragraphs_of('README.txt', 0).first.split(/\n/)[1..-1]
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.extra_deps << ['hpricot', '>= 0.5.0']
  p.clean_globs << 'coverage'
end

begin
  Rcov::RcovTask.new do |t|
    t.test_files = FileList['test/test*.rb']
    t.verbose = true
    t.rcov_opts << "--exclude rcov.rb,hpricot.rb,hpricot/.*\.rb"
  end
rescue NameError
end

# vim: syntax=Ruby
