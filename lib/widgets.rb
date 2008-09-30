require 'plugins/graphics/graphicsplugin'

module Widgets

class Widget
  attr_accessor :store
  
  def initialize
    @visible = true
    @changed = true
  end

  def Widget.graphics=(engine)
    @@engine=engine
  end
  
  def Widget.graphics
    @@engine
  end
  
  def hide
    @visible = false
    change!
  end
  
  def show(bool=true)
    change! if bool != @visible
    @visible = bool
  end
  
  def visible?  
    @visible
  end
  
  # Widgets should call super() to update changed status.
  def draw
    @changed = false
  end
  
  def size
    self.store.size
  end
  
  def h
    self.store.size[1]
  end
  
  def w
    self.store.size[0]
  end
  
  def changed?
    @changed
  end
  
  def change!
    @changed ||= true
  end
end

class Rect < Widget
  attr_reader :x,:y,:w,:h,:color
  def initialize(x,y,w,h,color)
    super()
    @x = x
    @y = y
    @w = w
    @h = h
    @color = color
    
    self.store = Widget.graphics.load_rect(w,h,color,self.store)
  end
  
  def x=(param)
    @x = param
    self.change!
  end
  
  def y=(param)
    @y = param
    self.change!
  end
  
  def w=(param)
    @w = param
    self.change!
  end
  
  def h=(param)
    @h = param
    self.change!
  end
  
  def color=(param,g=nil,b=nil)
    if not g.nil? and not b.nil?
      @color = [param,g,b]
    elsif param.is_a? Array
      @color = param
    else
      throw "#{param.inspect} is not a color!"
    end
    
    self.change!
  end
  
  def draw
    super
    self.store = Widget.graphics.rect(x,y,color,self.store) if self.visible?
  end
end

class Image < Widget
  attr_reader :x,:y,:alpha,:store
  
  def initialize(x,y,path)
    super()
    @x=x
    @y=y
    @path=path
    @alpha=1.0
    
    self.store = Widget.graphics.load_image(path,self.store)
  end
  
  def x=(x)
    @x = x
    self.change!
  end
  
  def y=(y)
    @y=y
    self.change!
  end
  
  def path=(path)
    @path = path
    self.store = Widget.graphics.load_image(path,self.store)
    self.change!
  end
  
  def size
    self.store.size
  end
  
  def size=(newsize)
    self.store = Widget.graphics.scale_image(newsize,self.store)
    self.change!
  end
  
  def scale(s)
    self.store = Widget.graphics.scale_image(s,self.store)
    self.change!
  end
  
  def scale_factor(current,desired)
    current/desired.to_f
  end
  
  def fit_inside(w,h)
    size = self.size

    factor = 1
    # Too wide & tall
    if w < size[0] and h < size[1]
      if w-size[0] > h-size[1]
        # fix width
        factor = w/size[0].to_f
      else
        # fix height
        factor = h/size[1].to_f
      end
    # Too wide
    elsif w < size[0]
      factor = w/size[0].to_f
    # Too tall
    elsif h < size[1]
      factor = h/size[1].to_f
    end
    self.store = Widget.graphics.scale_image(factor,self.store) if factor < 1
    self.change!
  end
  
  def draw
    super
    self.store = Widget.graphics.image(x,y,self.store) if self.visible?
  end
  
  def rotate(angle)
    self.store = Widget.graphics.rotate_image(angle,self.store)
    self.change!
  end
  
  def alpha=(alpha)
    @alpha = alpha
    self.store = Widget.graphics.set_image_alpha(alpha,self.store)
    self.change!
  end
end

class Font
  attr_accessor :italic,:underline,:bold,:color,:antialias
  attr_reader :store,:path,:size
  
  def initialize(path,size)
    @path=path
    @size=size
    @italic=false
    @underline=false
    @bold=false
    @color=[0,0,0]
    @antialias=true
    
    @store = Widget.graphics.load_font(self)
  end
  
  def size=(size)
    @size = size
    @store = Widget.graphics.load_font(self)
  end
end

class Label < Widget
  attr_reader :x,:y
  attr_reader :font,:string

  def initialize(x,y,string,font)
    super()
    @x=x
    @y=y
    @string=string
    @font=font
    
    self.store = Widget.graphics.load_label(@string,@font,self.store)
  end
  
  def x=(x)
    @x=x
    self.change!
  end
  
  def y=(y)
    @y=y
    self.change!
  end
  
  def reload
    self.store = Widget.graphics.load_label(@string,@font,self.store)
    self.change!
  end
  
  def font=(font)
    @font=font
    self.reload
  end
  
  def string=(str)
    @string=str
    self.reload
  end
  
  def draw
    super
    self.store = Widget.graphics.label(x,y,self.store) if self.visible?
  end
  
  def alpha=(aa)
    self.store = Widget.graphics.set_label_alpha(aa,store)
    self.change!
  end
end

end
