require 'rubygems'
require 'rubygame'
require 'rubygame/named_resource'
require 'plugins/graphics/graphicsplugin'
require 'opengl'
require 'lib/store'

class OpenGL < GraphicsPlugin
  include Rubygame
  
  def initialize
    Rubygame.init
    
    GL.set_attrib(GL::RED_SIZE,5)
    GL.set_attrib(GL::BLUE_SIZE,5)
    GL.set_attrib(GL::GREEN_SIZE,5)
    
    @clock = Clock.new
  end
  
  def framerate
    @clock.framerate
  end
  
  def setup
    return if @setup
    @setup = true
    GL.set_attrib(GL::DOUBLEBUFFER,1) if Plugin.preferences['Video.options'].include?("DOUBLEBUF")
    @clock.target_framerate=Plugin.preferences["Video.framerate"].to_i
    
    size = Plugin.preferences["Video.size"].split("x")
    size = [size[0].strip.to_i,size[1].strip.to_i]
    depth = (Plugin.preferences["Video.colordepth"].nil? ? 16 : Plugin.preferences["Video.colordepth"].to_i)
    GL.set_attrib(GL::DEPTH_SIZE,depth)
    
    opts = [OPENGL]
    opts.push FULLSCREEN if Plugin.preferences['Video.options'].include?("FULLSCREEN")
    Screen.set_mode(size,depth,opts)
    # TODO: show/hide cursor
    
    TTF.setup
    
    # Init opengl stuff
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity
    glOrtho(0, size[0], size[1], 0, 0, 1)
    glBlendFunc(GL_SRC_ALPHA,GL_ONE)
    glMatrixMode(GL_MODELVIEW)
    glDisable(GL_DEPTH_TEST)
    glEnable(GL_BLEND)
    
    # Textures
    tex_count = Plugin.preferences['Video.texture_count'].to_i
    tex_count = 128 if tex_count <= 0
    @tex_id = glGenTextures( tex_count ) # This needs to be global. Right now, we only get 1 texture ever. Sigh.
    @texture_id = 0
  end
  
  def redraw
    GL.swap_buffers
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
      puts "draw #{Time.now}"
      glClear(GL_COLOR_BUFFER_BIT)
      screen.drawlist.each { |widget| 
        widget.draw
      }
      self.redraw
    end
  end
  
  def close
    Rubygame.quit
  end
  
  # Widget implementation
  def load_rect(w,h,color,store)
    store = [w,h]
    return store
  end

  def rect(x,y,color,store)
    color = color.map { |i| (i > 1 ? i / 255.0 : i) }
    color[3] = 1.0 if color[3].nil?
    glBegin(GL_QUADS)
    glColor4f(color[0],color[1],color[2],color[3])
    glVertex2f(x,y)
    glVertex2f(x+store[0],y)
    glVertex2f(x+store[0],y+store[1])
    glVertex2f(x,y+store[1])
    glEnd
    return store
  end

  # Wrapper for Surface to implement autoloading. Maybe.
  class RawResource
    attr_accessor :surface,:size
  end
  
  class SDLRawResource < RawResource
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
    sdl_surf = SDLResource.new(path) { |path| Rubygame::Surface.load_image(path) }
    store = bind_surface(path,sdl_surf,@texture_id)
    @texture_id += 1
    return store
  end
  
  def bind_surface(path,sdl_surf,texture_id)
    glBindTexture(GL_TEXTURE_2D, @tex_id[texture_id])
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST)
    if path.downcase =~ /\.(jpg|jpeg)$/
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_NEAREST)
      gluBuild2DMipmaps(GL_TEXTURE_2D, 3, sdl_surf.size[0], sdl_surf.size[1], GL_RGB, GL_UNSIGNED_BYTE, sdl_surf.surface.pixels)
    else
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST)
      glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, sdl_surf.size[0], sdl_surf.size[1], 0, GL_RGBA, GL_UNSIGNED_BYTE, sdl_surf.surface.pixels)
    end
    store = Store.new( {:texture => texture_id,
              :sdl_surface => sdl_surf.surface,
              :width => sdl_surf.size[0],
              :height => sdl_surf.size[1],
              :alpha => 1.0,
              :path => path
            })
    return store
  end
  
  def image(x,y,store)
    glEnable(GL_TEXTURE_2D)
    glBindTexture(GL_TEXTURE_2D,@tex_id[store[:texture]])
    glBegin(GL_QUADS)
    glColor4f(1.0, 1.0, 1.0, store[:alpha])
    glTexCoord2f(0.0,0.0)
    glVertex2f(x,y)
    
    glTexCoord2f(1.0,0.0)
    glVertex2f(x+store[:width],y)
    
    glTexCoord2f(1.0,1.0)
    glVertex2f(x+store[:width],y+store[:height])
    
    glTexCoord2f(0.0,1.0)
    glVertex2f(x,y+store[:height])
    glEnd
    glDisable(GL_TEXTURE_2D)
    return store
  end

  def rotate_image(angle,store,aa=true)
    throw :not_implemented
    return store
  end

  def scale_image(size,store,aa=true)
    store[:width] *= size
    store[:height] *= size
    return store
  end
  
  def set_image_alpha(alpha,store)
    alpha /= 255.0 if alpha > 1
    store[:alpha] = alpha
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
    
    surf = font.render(string,true,font_widget.color)
    
    if store.nil? or store[:texture].nil?
      t_id = @texture_id
      @texture_id += 1
    else
      t_id = store[:texture]
    end
    resource = RawResource.new
    resource.size = surf.size
    resource.surface = surf
    store = bind_surface("text.png",resource,t_id)
    return store
  end
  
  def label(x,y,store)
    image(x,y,store)
  end
  
  def set_label_alpha(alpha,store)
    alpha /= 255.0 if alpha > 1
    store[:alpha] = alpha
    return store
  end
end
