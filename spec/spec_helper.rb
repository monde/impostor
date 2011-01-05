$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require "impostor"
require "rspec"

require 'rspec'

RSpec.configure do |config|
  config.mock_with :rspec

  #config.include Spec::Builders
  #config.include Spec::Helpers
  #config.include Spec::Indexes
  #config.include Spec::Matchers
  #config.include Spec::Path
  #config.include Spec::Rubygems
  #config.include Spec::Platforms
  #config.include Spec::Sudo
end


module WWW::Impostor::Test

  module Auth
  end

  module Post
  end

  module Topic
  end

end
