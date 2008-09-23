require 'plugins/background/backgroundplugin'
require 'lib/widgets'

class Ripple < BackgroundPlugin
  def setup
    prefs = Plugin.preferences
    color = [32,32,32]
    if prefs["Background.color"]
      color = prefs["Background.color"].split(",").map { |x| x.strip.to_i }
    end
    @bg = Widgets::Rect.new(0,0,prefs["Video.width"],prefs["Video.height"],color)
    
    @boxes = []
    5.times { @boxes.push create_box }
  end
  
  def create_box(max_w = 100)
    width = rand*(max_w)
    r=g=b=rand*255
    return [[0,0],[0,Plugin.preferences['Video.height']],[r,g,b,rand*32],rand*3+5,width]
  end
  
  def update
    @bg.store[0].fill(@bg.store[1])
    @boxes.each { |box|
      @bg.store[0].draw_box_s(box[0],box[1],box[2])
      box[0][0] += box[3] if box[1][0] > box[4]
      box[1][0] += box[3]/2.0
      if box[0][0] >= box[1][0]
        box.replace create_box
      end
    }
    @bg.change!
    self.change!
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
