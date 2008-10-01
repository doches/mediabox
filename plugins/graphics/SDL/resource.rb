  # Wrapper for Surface to implement autoloading. Maybe.
  class SDLRawResource
    attr_accessor :surface
    
    def initialize( name, &blk )
      Plugin.loader.screens.autoload_dirs.each { |dir|
        if File.exists?(File.join(dir,name))
          Mediabox::Logger.log("Loading resource #{name} ... OK")
          path = "#{dir}/#{name}"
          @surface = blk.call(path)
          return
        end
      }
      throw LoadError.new("#{name} not found")
    end
    
    def size
      @surface.size
    end
  end

  class SDLResource < SDLRawResource
    def initialize(name, &blk)
      begin
        super
      rescue LoadError
        Mediabox::Logger.log("Loading resource #{name} ... FAILED")
        @surface = Rubygame::Surface.new([64,64])
        @surface.fill([255,0,0])
        begin
          @surface.set_alpha(128)
        rescue
          ;
        end
      end
    end
  end
