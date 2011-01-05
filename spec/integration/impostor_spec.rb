require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe "an impostor" do

  it "have a version" do
    im = WWW::Impostor.new(:type => :test)
    im.version.should == "0.3.0"
  end

  it "should post a message" do
    im = WWW::Impostor.new(:type => :test)
    im.post(formum=1, topic=2, message="Hello World").should == {
      :forum => 1,
      :topic => 2,
      :message => "Hello World",
      :result => true
    }
  end

end
