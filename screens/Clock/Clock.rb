require 'screens/screen'
require 'lib/widgets'

class Clock < Screen
  def initialize
    super
    shadowfont = Widgets::Font.new("trebuc.ttf",256)
    shadowfont.color = [16,16,16]
    font = Widgets::Font.new("trebuc.ttf",256)
    font.color = [255,255,255]
    @time = Widgets::Label.new(0,0,"?",font)    
    @shadow = Widgets::Label.new(0,0,"?",shadowfont)
    
    dshadowfont = Widgets::Font.new("trebuc.ttf",64)
    dshadowfont.color = [16,16,16]
    dfont = Widgets::Font.new("trebuc.ttf",64)
    dfont.color = [255,255,255]
    @date = Widgets::Label.new(0,0,"?",dfont)
    @dshadow = Widgets::Label.new(0,0,"?",dshadowfont)
    
    add(@shadow)
    add(@time)
    add(@dshadow)
    add(@date)
  end
  
  def update
    newtime = Time.now.strftime("%I:%M %p")
    if @time.string != newtime
      @time.string = newtime
      @time.x = preferences['Video.width']/2 - @time.w/2
      @time.y = preferences['Video.height']/2 - @time.h/2
      @shadow.string = @time.string
      @shadow.x = @time.x + 5
      @shadow.y = @time.y + 5
      
      @date.string = Time.now.strftime("%d %B").gsub(/^0/,"")
      @dshadow.string = @date.string
      @date.x = preferences['Video.width']/2 - @date.w/2
      @date.y = @time.y + @time.h - 60
      @dshadow.x = @date.x + 5
      @dshadow.y = @date.y + 5
    end
  end
end
