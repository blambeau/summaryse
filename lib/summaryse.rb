require "summaryse/version"
require "summaryse/loader"
module Summaryse

  #
  # Registers a aggregation function under a given name.
  #
  # The lambda function is converted as a Proc from the supplied block.
  # It takes one array argument, on which the aggregation must be done
  # and returned.
  #
  # @param [Symbol] name a aggregation function name
  # @param [lambda] the function itself
  # 
  def self.register(name, &lambda)
    @aggregators ||= {}
    @aggregators[name] = lambda
  end

  #
  # Returns an aggregator by name, nil if no such aggregator as been
  # previously registered.
  #
  def self.aggregator(name)
    @aggregators && @aggregators[name]
  end

  #
  register(:count)       {|a| a.size                     }
  register(:sum)         {|a| a.inject(:+)               }
  register(:avg)         {|a| a.inject(:+)/a.size.to_f   }

  # 
  register(:first)       {|a| a.first                    }
  register(:last)        {|a| a.last                     }
  register(:min)         {|a| a.min                      }
  register(:max)         {|a| a.max                      }

  #
  register(:intersection){|a| a.inject(:&)               }
  register(:union)       {|a| a.inject(:|)               }

end # module Summaryse
require "summaryse/core_ext/array"

