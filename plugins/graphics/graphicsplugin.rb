require 'plugins/plugin'

class GraphicsPlugin < Plugin
  def setup
    throw :not_implemented
  end
  
  def redraw
    throw :not_implemented
  end
  
  def draw(screen)
    throw :not_implemented
  end
  
  # Optional, returns the current framerate
  def framerate
    ;
  end
end
