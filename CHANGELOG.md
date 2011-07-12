# 1.1.0 / FIX ME

  * Added a way to register user-defined aggregation functions:

        Summaryse.register(:comma_join) do |ary|
          ary.join(', ')
        end
        [1, 4, 12, 7].summaryse(:comma_join) 
        # => "1, 4, 12, 7"

  * Added the ability to specify aggregations on hash keys that are not used at
    all. In this case, the aggregator is called on an empty array.

        [
          { :size => 12 },
          { :size => 17 }
        ].summaryse(:size => :max, :hobbies => lambda{|a| a})
        # => {:size => 17, :hobbies => []}

  * Added the ability to use objects responding to to_summaryse as aggregator
    functions:

        class Foo
          def to_summaryse; :sum; end
        end
        [1, 2, 3].summaryse(Foo.new)
        # => 6

  * Added the ability to explicitly bypass Hash entries as the result of a 
    computation, by returning Summaryse::BYPASS

        [
          { :hobbies => [:ruby],  :size => 12 },
          { :hobbies => [:music], :size => 17 }
        ].summaryse(:size => :max, :hobbies => lambda{|a| Summaryse::BYPASS})
        # => {:size => 17}

  * The semantics of aggregating empty arrays is guaranteed. Due to duck typing, 
    nil is returned in almost all cases except :count so far. This is specified
    in README.

  * Best-effort for yielding friendly hash ordering under ruby >= 1.9
  
  * Array#summaryse now raises an ArgumentError when it does not understand its
    aggregator argument.

# 1.0.0 / 2011.07.11

* Enhancements

  * Birthday!
