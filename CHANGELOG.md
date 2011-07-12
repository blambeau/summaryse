# 1.1.0 / FIX ME

  * Added a way to register user-defined aggregation functions:

        Summaryse.register(:comma_join) do |ary|
          ary.join(', ')
        end
        [1, 4, 12, 7].summaryse(:comma_join) # => "1, 4, 12, 7"

  * Added the ability to specify aggregations on hash keys that are not used at
    all. In this case, the aggregator is called on an empty array.

        [
          { :hobbies => [:ruby],  :size => 12 },
          { :hobbies => [:music], :size => 17 }
        ].summaryse(:hello => lambda{|a| a})
        # => {:hello => []}

  * Added the ability to use objects responding to to_summaryse as aggregator
    functions:

        class Foo
          def to_summaryse; :sum; end
        end
        [1, 2, 3].summaryse(Foo.new).should eq(6)

  * Added the ability to explicitly bypass Hash entries as the result of a 
    computation, by returning Summaryse::BYPASS

        [
          { :hobbies => [:ruby],  :size => 12 },
          { :hobbies => [:music], :size => 17 }
        ].summaryse(:size => :max, :hobbies => lambda{|a| Summaryse::BYPASS})
        # => {:size => "17"}

  * The semantics of aggregating empty arrays is specified in README. Due to
    duck typing, this means that nil is returned in almost all cases.

  * Best-effort for yielding friendly hash ordering under ruby >= 1.9
  
  * Array#summaryse now raises an ArgumentError if it does not understand its
    aggregator argument.

# 1.0.0 / 2011.07.11

* Enhancements

  * Birthday!
