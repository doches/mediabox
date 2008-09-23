require 'rubygems'
require 'rubygame'
require 'rubygame/named_resource'
require 'plugins/graphics/graphicsplugin'

class SDL < GraphicsPlugin
  include Rubygame
  
  def initialize
    Rubygame.init
    @clock = Clock.new
  end
  
  def framerate
    @clock.framerate
  end
  
  def setup
    return if @setup
    @setup = true
    @clock.target_framerate=Plugin.preferences["Video.framerate"].to_i
    
    size = Plugin.preferences["Video.size"].split("x")
    size = [size[0].strip.to_i,size[1].strip.to_i]
    depth = (Plugin.preferences["Video.colordepth"].nil? ? 0 : Plugin.preferences["Video.colordepth"].to_i)
    options = eval("[#{Plugin.preferences['Video.options']}]")
    
    @screen = Screen.new(size, depth, options)
    @screen.show_cursor = (Plugin.preferences["Video.showcursor"] == "true" ? true : false)
    
    TTF.setup
  end
  
  def redraw
    @screen.flip
  end
  
  # Draw the widgets in screen's drawlist, if any of them have changed.
  def draw(screen)
    @clock.tick
    # Do we need to redraw the screen?
    do_redraw = Plugin.loader.background.changed?
    screen.drawlist.each { |widget| 
      if widget.changed?
        do_redraw = true
        break
      end
    } if not do_redraw
    # Ok, redraw it
    if do_redraw
      screen.drawlist.each { |widget| widget.draw }
      @screen.flip
    end
  end
  
  def close
    Rubygame.quit
  end
  
  # Widget implementation
  def load_rect(w,h,color,store)
    store = [nil,nil] if store.nil?
    store[0] = Surface.new([w,h]) if store[0].nil?
    if store[1] != color
      store[0].fill(color)
      store[1] = color
    end
    return store
  end

  def rect(x,y,color,store)
    if store[1] != color
      store[0].fill(color)
      store[1] = color
    end
    store[0].blit(@screen,[x,y])
    return store
  end

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

  def load_image(path,store)
    store = SDLResource.new(path) { |path| Rubygame::Surface.load_image(path) }
  end

  def image(x,y,store=nil)
    store.surface.blit(@screen,[x,y])
    return store
  end

  def rotate_image(angle,store,aa=true)
    store.surface = store.surface.rotozoom(angle,0,aa)
    return store
  end

  def scale_image(size,store,aa=true)
    store.surface = store.surface.rotozoom(0,size,aa)
    return store
  end
  
  def set_image_alpha(alpha,store)
    store.surface.set_alpha(alpha)
    return store
  end

  def load_font(font)
    res = SDLRawResource.new(font.path) { |path| TTF.new(path,font.size) }
    return res.surface
  end
  
  def load_label(string,font_widget,store)
    font = font_widget.store
    font.bold = font_widget.bold
    font.italic = font_widget.italic
    font.underline = font_widget.underline
    
    store = font.render(string,font_widget.antialias,font_widget.color)
    return store
  end
  
  def label(x,y,store)
    store.blit(@screen,[x,y])
    return store
  end
  
  def set_label_alpha(alpha,store)
    store.set_alpha alpha
    return store
  end
end
