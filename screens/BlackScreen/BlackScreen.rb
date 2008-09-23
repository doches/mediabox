require 'screens/screen'
require 'lib/widgets'

class BlackScreen < Screen
  def initialize
    super
    
    @bg = Widgets::Rect.new(0,0,preferences['Video.width'],preferences['Video.height'],[0,0,0])
    add( @bg )
  end
  
  def on_focus
    @bg.change!
  end
  
  def process(msg)
    # do nothing
  end
  
  def update
    # do nothing
  end
end
