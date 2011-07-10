require File.expand_path('../spec_helper', __FILE__)
describe Summarize do
  
  it "should have a version number" do
    Summarize.const_defined?(:VERSION).should be_true
  end
  
end
