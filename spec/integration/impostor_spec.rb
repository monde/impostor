require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe "an impostor" do

  it "should have a version" do
    impostor.version.should == "0.3.0"
  end

  it "should post a message" do
    impostor.post(formum=1, topic=2, message="Hello World").should == {
      :forum => 1,
      :topic => 2,
      :message => "Hello World",
      :result => true
    }
  end

  it "should create a new topic with a given subject and initial message" do
    impostor.new_topic(formum=1, subject="No Teapots!", message="Hello World").should == {
      :forum => 1,
      :subject => "No Teapots!",
      :message => "Hello World",
      :result => true
    }
  end

end
