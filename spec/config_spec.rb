require File.join(File.dirname(__FILE__), 'spec_helper')

describe "impostor's configuration" do

  it "should key off symbols or strings" do
    config = config(:foo => "bar")
    config.config(:foo).should == "bar"
    config.config("foo").should == "bar"
  end

  it "should have an app root" do
    config(:app_root => "http://example.com").app_root.
      should == "http://example.com"
  end

end
