require File.join(File.dirname(__FILE__), 'spec_helper')

describe "impostor's configuration" do

  it "should have a configuration" do
    config.app_root.should == "http://example.com"
  end

end
