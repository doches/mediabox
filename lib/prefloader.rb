module Mediabox

class PreferencesLoader
  attr_reader :keys
  
  def initialize(filename)
    @keys = {}
    
    begin
      file = IO.readlines(filename)
      
      file.each { |line|
        line.strip!
        if not line =~ /(^#)|(^\s*$)/
          sline = line.split("=",2)
          @keys[sline[0].strip] = sline[1].strip
        end
      }
    rescue
      p $!
    end
    
    # Create some convenient preferences for screenwriters
    if not @keys["Video.size"].nil?
      dim = @keys["Video.size"].split("x")
      @keys["Video.width"] = dim[0].strip.to_i
      @keys["Video.height"] = dim[1].strip.to_i
    end
  end
  
  def each(&blk)
    @keys.each { |k,v| blk.call(k,v) }
  end
  
  def each_key(&blk)
    @keys.each_key { |k| blk.call(k) }
  end
  
  def [](key)
    @keys[key]
  end
  
  def []=(key,value)
    @keys[key] = value
  end
end

end
