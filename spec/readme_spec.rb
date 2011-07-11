require File.expand_path('../spec_helper', __FILE__)
describe "README file" do

  it 'should provide correct examples' do

    # :count, same as #size
    [1, 4, 12, 7].summaryse(:count).should eq(4)

    # :sum, same as #inject(:+)
    [1, 4, 12, 7].summaryse(:sum).should eq(24)

    # :avg, same as #inject(:+)/size
    [1, 4, 12, 7].summaryse(:avg).should eq(6.0)

    # :min, same as #min
    [1, 4, 12, 7].summaryse(:min).should eq(1)

    # :max, same as #max
    [1, 4, 12, 7].summaryse(:max).should eq(12)

    # :first, same as #first
    [1, 4, 12, 7].summaryse(:first).should eq(1)

    # :last, same as #last
    [1, 4, 12, 7].summaryse(:last).should eq(7)

    # :union, same as #inject(:|)
    [ [1, 4], [12, 1, 7], [1] ].summaryse(:union).should eq([1, 4, 12, 7])

    # :intersection, same as #inject(:&)
    [ [1, 4], [12, 1, 7], [1] ].summaryse(:intersection).should eq([1])

    [
      { :hobbies => [:ruby],  :size => 12 },
      { :hobbies => [:music], :size => 17 }
    ].summaryse(:hobbies => :union, :size => :max).should eq(
      :hobbies => [:ruby, :music], :size => 17
    )

    [
      { :hobbies => [:ruby],  :size => 12 },
      { :hobbies => [:music], :size => 17 }
    ].summaryse(:hobbies => :union, nil => :first).should eq(
      :hobbies => [:ruby, :music], :size => 12
    )

    [
      { :hobbies => [:ruby],  :size => 12 },
      { :hobbies => [:music], :size => 17 }
    ].summaryse(:hobbies => :union, :size => lambda{|a|
      a.inject(:+).to_f
    }).should eq(:hobbies => [:ruby, :music], :size => 29.0)

    [
      { :hobbies => [:ruby],  :size => 12 },
      { :hobbies => [:music], :size => 17 }
    ].summaryse(:hobbies => :union, :size => lambda{|a|
      a.join(', ')
    }).should eq(:hobbies => [:ruby, :music], :size => "12, 17")

    [ 
      { :hobbies => {:day => [:ruby], :night => [:ruby] } },
      { :hobbies => {:day => [],      :night => [:sleep]} }
    ].summaryse(:hobbies => {:day => :union, :night => :union}).should eq(
      :hobbies => {:day => [:ruby], :night => [:ruby, :sleep]}
    )

  end

  it 'should provide a correct integration example' do
    # This is left.yaml
    left = YAML.load <<-Y
      hobbies:
        - ruby
        - rails
      dependencies:
        - {name: rspec, version: '2.6.4', for: [ runtime ]}
    Y

    # This is right.yaml
    right = YAML.load <<-Y
      hobbies:
        - ruby
        - music
      dependencies:
        - {name: rails, version: '3.0',   for: [ runtime ]}
        - {name: rspec, version: '2.6.4', for: [ test    ]}
    Y

    # This is merge.yaml
    merge = YAML.load <<-M
      hobbies: 
        :union
      dependencies: 
        - [name, version]
        - for: :union
    M
    
    # Merge and re-dump
    exp = YAML.load <<-Y
      hobbies:
        - ruby
        - rails
        - music
      dependencies:
        - {name: rspec, version: '2.6.4', for: [ runtime, test ]}
        - {name: rails, version: '3.0',   for: [ runtime       ]}
    Y
    [ left, right ].summaryse(merge).should eq(exp)
  end

end
