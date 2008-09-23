require 'screens/screen'
require 'lib/widgets'

class DateScreen < Screen
  def initialize
    super
      
    font = Widgets::Font.new("trebuc.ttf",256)
    font.color = [255,255,255]
    @time = Widgets::Label.new(0,0,"?",font)
    
    shadowfont = Widgets::Font.new("trebuc.ttf",256)
    shadowfont.color = [64,64,64]
    @shadow = Widgets::Label.new(0,0,"?",shadowfont)
    add(@shadow)
    add(@time)
  end
  
  def update
    newtime = Time.now.strftime("%d %b")
    if @time.string != newtime
      @time.string = newtime
      @time.x = preferences['Video.width']/2 - @time.w/2
      @time.y = preferences['Video.height']/2 - @time.h/2
      @shadow.string = @time.string
      @shadow.x = @time.x + 10
      @shadow.y = @time.y + 10
    end
  end
end
