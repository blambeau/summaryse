require File.expand_path('../spec_helper', __FILE__)
describe Summarize do
  
  it "should have a version number" do
    Summarize.const_defined?(:VERSION).should be_true
  end

  let(:numbers){ [15, 3, 17, 4, 12] } 
  let(:arrays){ [[15, 3, 12], [17, 4, 12]] } 

  describe "when called with a simple symbol" do
    
    it "should recognize avg" do
      numbers.summarize(:avg).should eq((15 + 3 + 17 + 4 + 12)/5.0)
    end
    
    it "should recognize count" do
      numbers.summarize(:count).should eq(5)
      arrays.summarize(:count).should eq(2)
    end

    it "should recognize intersection" do
      arrays.summarize(:intersection).should eq([12])
    end

    it "should recognize min" do
      numbers.summarize(:min).should == 3
    end

    it "should recognize max" do
      numbers.summarize(:max).should == 17
    end

    it "should recognize sum" do
      numbers.summarize(:sum).should eq(15 + 3 + 17 + 4 + 12)
      arrays.summarize(:sum).should eq([ 15, 3, 12, 17, 4, 12])
    end

    it "should recognize union" do
      arrays.summarize(:union).should == [15, 3, 12, 17, 4]
    end

  end
  
end
