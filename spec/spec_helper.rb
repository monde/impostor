$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require "impostor"
require "rspec"

require 'rspec'

RSpec.configure do |config|
  config.mock_with :rspec
end

module WWW::Impostor::Test

  module Auth
  end

  module Post
  end

  module Topic
  end

end
