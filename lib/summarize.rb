class Array

  def summarize(agg)
    case agg
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
      each do |tuple| 
        (agg.keys & tuple.keys).each{|k| big[k] << tuple[k]}
      end
      Hash[big.collect{|k,v| [k,v.summarize(agg[k])]}]
    when Array
      by, agg = agg
      grouped = Hash.new{|h,k| h[k] = []}
      flatten.each{|tuple| grouped[tuple[by]] << tuple}
      grouped.values.collect{|rel| rel.summarize(agg)}
    end
  end

end
require "summarize/version"
require "summarize/loader"
