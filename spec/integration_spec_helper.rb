require File.join(File.dirname(__FILE__), 'base_spec_helper')
require 'vcr'

VCR.config do |c|
  c.cassette_library_dir = File.join(File.dirname(__FILE__), 'fixtures/vcr_cassettes')
  c.stub_with :webmock # or :fakeweb
end
