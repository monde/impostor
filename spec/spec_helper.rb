$:.unshift File.expand_path('../../lib', __FILE__)

require "impostor"

require 'rspec'
require 'caged_net_http'
require 'impostor_spec_helper'
require 'test_impostor'

RSpec.configure do |config|
  config.mock_with :rspec
  config.include ImpostorSpecHelper
end
