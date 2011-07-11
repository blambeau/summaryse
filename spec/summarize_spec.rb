require File.expand_path('../spec_helper', __FILE__)
describe Summarize do
  
  it "should have a version number" do
    Summarize.const_defined?(:VERSION).should be_true
  end

  describe "when called with a Proc argument" do

    let(:numbers){ [15, 3, 17, 4, 12] } 

    it "should simply call the proc with the array" do
      numbers.summarize(lambda{|a| "hello"}).should eq("hello")
    end
   
  end 

  describe "when called with a Symbol argument" do
    
    let(:numbers){ [15, 3, 17, 4, 12] } 
    let(:arrays){ [[15, 3, 12], [17, 4, 12]] } 

    it "should recognize avg" do
      numbers.summarize(:avg).should eq((15 + 3 + 17 + 4 + 12)/5.0)
    end
    
    it "should recognize count" do
      numbers.summarize(:count).should eq(5)
      arrays.summarize(:count).should eq(2)
    end

    it "should recognize first" do
      numbers.summarize(:first).should eq(15)
    end

    it "should recognize intersection" do
      arrays.summarize(:intersection).should eq([12])
    end

    it "should recognize last" do
      numbers.summarize(:last).should eq(12)
    end

    it "should recognize min" do
      numbers.summarize(:min).should eq(3)
    end

    it "should recognize max" do
      numbers.summarize(:max).should eq(17)
    end

    it "should recognize sum" do
      numbers.summarize(:sum).should eq(15 + 3 + 17 + 4 + 12)
      arrays.summarize(:sum).should eq([ 15, 3, 12, 17, 4, 12])
    end

    it "should recognize union" do
      arrays.summarize(:union).should eq([15, 3, 12, 17, 4])
    end

  end # Symbol argument

  describe "when called with a Hash argument" do

    let(:rel){[
      { :size => 12, :hobbies => [:ruby] },
      { :size => 1,  :hobbies => [:music] }
    ]}

    it "should allow simple sub-summarizations" do
      control = { :size => :max, :hobbies => :union }
      rel.summarize(control).should eq(:size => 12, :hobbies => [:ruby, :music])
    end

    it "should not keep non summarized arguments by default" do
      control = {:size => :max}
      rel.summarize(control).should eq(:size => 12)
    end

    it "should allow specifying a default behavior" do
      control = {:size => :max, nil => :union}
      rel.summarize(control).should eq(:size => 12, :hobbies => [:ruby, :music])
    end

    it "should support having inner Procs" do
      control = {:size => lambda{|a| "hello"}}
      rel.summarize(control).should eq(:size => "hello")
    end

  end # Hash argument

  describe "when called with an Array argument" do
    let(:array){[
      [ {:version => "1.9", :size => 16},
        {:version => "1.8", :size => 12} ],
      [ {:version => "2.0", :size => 99},
        {:version => "1.8", :size => 10} ]
    ]}

    it "should union then summarize while respecting by key order" do
      control = [ [:version], {:size => :min} ]
      array.summarize(control).should eq([
        {:version => "1.9", :size => 16},
        {:version => "1.8", :size => 10},
        {:version => "2.0", :size => 99}
      ])
    end

  end
  
end
