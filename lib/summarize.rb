class Array

  def summarize(agg)
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
          [k,v.summarize(summ)]
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
      keys.uniq.collect{|key| grouped[key].summarize(agg)}
    end
  end

end
require "summarize/version"
require "summarize/loader"
