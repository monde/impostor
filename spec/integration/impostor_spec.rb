require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe "an impostor" do

  it "have a version" do
    im = WWW::Impostor.new(:type => :test)
    im.version.should == "0.3.0"
  end

end
