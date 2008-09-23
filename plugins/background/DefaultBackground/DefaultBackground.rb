require 'plugins/background/backgroundplugin'
require 'lib/widgets'

class DefaultBackground < BackgroundPlugin
  def setup
    prefs = Plugin.preferences
    if prefs["Background.color"]
      color = prefs["Background.color"].split(",").map { |x| x.strip.to_i }
      @bg = Widgets::Rect.new(0,0,prefs["Video.width"],prefs["Video.height"],color)
    end
  end
  
  def color=( array, g=nil, b=nil )
    array = [array,g,b] if not g.nil? and not b.nil?
    @bg.color = array
  end
  
  def color
    @bg.color
  end
  
  def draw
    super
    @bg.draw
  end
  
  def redraw
    @bg.change!
    self.draw
  end
end
