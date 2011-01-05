# -*- ruby -*-

begin
  require 'hoe'
rescue LoadError
  require 'rubygems'
  require 'hoe'
end
require 'rspec'
require 'rspec/core/rake_task'

$LOAD_PATH.unshift 'lib'
require 'impostor'

Hoe.plugin :bundler, :git
Hoe.spec('impostor') do |p|
  p.version = WWW::Impostor::VERSION
  p.rubyforge_name = 'impostor'
  p.author = 'Mike Mondragon'
  p.email = 'mikemondragon@gmail.com'
  p.summary = 'imPOSTor posts messages to non-RESTful forums and blogs'
  p.description = p.paragraphs_of('README.txt', 2..5).join("\n\n")
  p.url = p.paragraphs_of('README.txt', 0).first.split(/\n/)[1..-1]
  p.readme_file = "README.txt"
  p.history_file = "History.txt"
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.extra_deps << ['nokogiri', '>= 1.4.4']
  p.extra_deps << ['mechanize', '>= 1.0.0']
  p.clean_globs << 'coverage'
  p.testlib = :rspec
end

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

# vim: syntax=Ruby
