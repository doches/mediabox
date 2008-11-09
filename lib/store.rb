  class Store
    def initialize(hash)
      @hash = hash
    end
    
    def []=(k,v)
      @hash[k] = v
    end
    
    def [](k)
      @hash[k]
    end
    
    def size
      [@hash[:width],@hash[:height]]
    end
  end
