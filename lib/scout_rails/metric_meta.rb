# Contains the meta information associated with a metric. Used to lookup Metrics in to Store's metric_hash.
class ScoutRails::MetricMeta
  def initialize(metric_name, options = {})
    @metric_name = metric_name
    @metric_id = nil
    @scope = Thread::current[:scout_sub_scope] || Thread::current[:scout_scope_name]
    @desc = options[:desc]
    @extra = {}
  end
  attr_accessor :metric_id, :metric_name
  attr_accessor :scope
  attr_accessor :client_id
  attr_accessor :desc, :extra
  
  # To avoid conflicts with different JSON libaries
  def to_json(*a)
     %Q[{"metric_id":#{metric_id || 'null'},"metric_name":#{metric_name.to_json},"scope":#{scope.to_json || 'null'}}]
  end
  
  def ==(o)
    self.eql?(o)
  end
  
  def hash
     h = metric_name.hash
     h ^= scope.hash unless scope.nil?
     h ^= desc.hash unless desc.nil?
     h
   end
   
   def <=>(o)
     namecmp = self.name <=> o.name
     return namecmp if namecmp != 0
     scopecmp = (self.scope || '') <=> (o.scope || '')
     return scopecmp if scopecmp != 0
     (self.desc || '') <=> (o.desc || '') 
   end

  def eql?(o)
   self.class == o.class && metric_name.eql?(o.metric_name) && scope == o.scope && client_id == o.client_id && desc == o.desc
  end
end # class MetricMeta