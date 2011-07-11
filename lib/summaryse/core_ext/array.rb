class Array

  #
  # Apply a summarization to self
  #
  # == Base
  #
  # Basic summarization operators are 
  #   * :avg, :count, :sum
  #   * :mix, :max, :first, :last
  #   * :union, :intersection
  #
  # They suppose the existence of the corresponding dyadic operators like 
  # '+' (i.e. sum, avg), '|' (union), '&' (intersection) on the array values.
  #
  # Example:
  #     [1, 4, 12, 7].summaryse(:sum)   # => 24
  #
  # == Hashes
  #
  # Summarizing arrays of hashes may be done by passing an hash of summarization
  # expressions. Calls will be made recursively in this case:
  #
  # Example: 
  #     [
  #       { :hobbies => [:ruby],  :size => 12 },
  #       { :hobbies => [:music], :size => 17 }
  #     ].summaryse(:hobbies => :union, :size => :max)
  #     # => {:hobbies => [:ruby, :music], :size => 17}
  #
  # Use the nil key to specify the default aggregation to apply if not explcitely
  # specified. A Proc object can also be passed as aggregation operator. In this
  # case, it will be called with the array of values on which the aggregation
  # must be done:
  #
  #     # In the example below, hobbies are summarized through default behavior
  #     # provided by the nil key. Sizes are summarized by the lambda. 
  #     [
  #       { :hobbies => [:ruby],  :size => 12 },
  #       { :hobbies => [:music], :size => 17 }
  #     ].summaryse(nil => :union, :size => lambda{|a| a.join(',')})
  #     # => {:hobbies => [:ruby, :music], :size => "12,17"}
  # 
  # == Arrays of Hashes
  #
  # Summarizing arrays of arrays of hashes may be done by passing an array of 
  # two values. The first one is a 'by key', the second is the summarization 
  # hash to apply.
  #
  # Example:
  #     [ 
  #       [ { :name => :yard,      :for => [ :devel   ] },
  #         { :name => :summaryse, :for => [ :runtime ] } ],
  #       [ { :name => :summaryse, :for => [ :devel   ] }, 
  #         { :name => :treetop,   :for => [ :runtime ] } ]
  #     ].summaryse([ [:name], {:for => :union} ])
  #     # => [ {:name => :yard,      :for => [:devel]           },
  #     #      {:name => :summaryse, :for => [:devel, :runtime] },
  #     #      {:name => :treetop,   :for => [:runtime]         } ]
  #
  def summaryse(agg)
    case agg
    when Proc
      agg.call(self)
    when :avg
      inject(:+).to_f/size
    when :count
      size
    when :intersection
      inject(:&)
    when :sum
      inject(:+)
    when :union
      inject(:|)
    when Symbol
      self.send(agg)
    when Hash
      big = Hash.new{|h,k| h[k] = []}
      each{|t| t.each_pair{|k,v| big[k] << v}}
      Hash[big.collect{|k,v|
        if summ = (agg[k] || agg[nil])
          [k,v.summaryse(summ)]
        end
      }.compact]
    when Array
      by, agg = agg
      keys = []
      grouped = Hash.new{|h,k| h[k] = []}
      flatten.each{|t|
        key = Hash[by.collect{|k| [k, t[k]] }]
        keys << key
        grouped[key] << t
      }
      agg = agg.merge(Hash[by.collect{|k| [k, :first]}])
      keys.uniq.collect{|key| grouped[key].summaryse(agg)}
    end
  end

end