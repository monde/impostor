$:.unshift File.expand_path('../../lib', __FILE__)

require "impostor"

require 'rspec'
require 'impostor_spec_helper'
require 'test_impostor'
require 'fake_impostor'

RSpec.configure do |config|
  config.mock_with :rspec
  config.include ImpostorSpecHelper
end
