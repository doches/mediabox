require 'screens/screen'
require 'lib/widgets'

class Slideshow < Screen
  Interval = (Screen.preferences["Slideshow.interval"].nil? ? 10 : Screen.preferences["Slideshow.interval"].to_i)
  
  def initialize
    super
    @rect = Widgets::Rect.new(0,0,Screen.preferences["Video.width"],Screen.preferences["Video.height"],[0,0,0,128])
    add( @rect )
    
    @files = []
    @index = 0
    dirs = Screen.preferences["Slideshow.directories"].split(/[, ]+/)
    dirs.each do |path|
      path = "#{path}/" if not path[path.size-1].chr == "/"
      Dir.foreach(path) { |file| @files.push("#{path}#{file}") if file.downcase =~ /(jpg)|(png)|(jpeg)$/ }
    end
    @index = (rand * @files.size-1).to_i
    @old_tick = Time.now.to_i
    
    @fadestep = (Screen.preferences["Slideshow.fade"] || 2).to_i
    
    @image = Widgets::Image.new(0,0,@files[@index])
    @image.fit_inside(Screen.preferences["Video.width"],Screen.preferences["Video.height"])
    @image.x = Screen.preferences["Video.width"]/2 - @image.size[0]/2
    @image.y = Screen.preferences["Video.height"]/2 - @image.size[1]/2
    @image.alpha = 0
    
    @image2 = Widgets::Image.new(0,0,@files[@index])
    @image2.fit_inside(Screen.preferences["Video.width"],Screen.preferences["Video.height"])
    @image2.x = Screen.preferences["Video.width"]/2 - @image2.size[0]/2
    @image2.y = Screen.preferences["Video.height"]/2 - @image2.size[1]/2

    add( @image2 )
    add( @image )
    
    @current = @image
    @paused = false
  end
    
  def process(msg)
    case msg
      when Messages::Up
        @index -= 1
        @index = @files.size-1 if @index < 0
        reload
      when Messages::Down
        @index += 1
        @index = 0 if @index >= @files.size
        reload
      when Messages::Pause
        @paused = !@paused
    end
  end
  
  def reload
    begin
    @old_tick = Time.now.to_i
    @image2.alpha = 0
    @image2.store = @image.store
    @image2.x = @image.x
    @image2.y = @image.y
    @image2.show(false)
    @image.path = @files[@index]
    @image.fit_inside(Screen.preferences["Video.width"],Screen.preferences["Video.height"])
    @image.x = Screen.preferences["Video.width"]/2 - @image.size[0]/2
    @image.y = Screen.preferences["Video.height"]/2 - @image.size[1]/2
    @image.alpha = 255
    rescue Error
      Mediabox::Logger.log($!)
    end
  end
  
  def update
    tick = Time.now.to_i
    if @fade
      if @image.alpha < 255
        @image.alpha += @fadestep
        @image2.alpha -= @fadestep
        
        @image.alpha = 255 if @image.alpha > 255
        @image2.alpha = 0 if @image2.alpha < 0
      else
        @image2.alpha = 0
        @fade = false
      end
    end
    if tick - @old_tick > Interval and not @paused
      @index += 1
      @index = 0 if @index >= @files.size
      
      reload
      @image2.show
      @image.show
      @image2.alpha = 255
      @image.alpha = 0
      @fade = true
    end
  end
end
