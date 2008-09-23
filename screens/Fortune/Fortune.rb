require 'screens/screen'
require 'lib/widgets'

class Fortune < Screen
  def initialize
    super
      
    @init_font_size = 128
    @font_interval = 10
      
    @font = Widgets::Font.new("trebuc.ttf",@init_font_size)
    @font.color = [255,255,255]
    @line = Widgets::Label.new(0,0," ",@font)
    add @line
    
    @lines = []
    
    @interval = preferences['Fortune.interval'].to_i
    @interval = 60 if @interval.nil? or @interval == 0
    @last_tick = Time.now.to_i - @interval-1
  end
  
  def resize_to_fit(count)
    longest = nil
    @lines.each do |line|
      longest ||= line
      longest = line if line.w > longest.w
    end
    while longest.w > preferences['Video.width'] - 10
      @font.size /= 2
      longest.font = @font
    end
    x = preferences['Video.width']/2 - longest.w/2
    y = preferences['Video.height']/2 - (longest.h * count)/2
    @lines.each do |line|
      line.font = @font
      line.x = x
      line.y = y
      y += line.h
    end
  end
  
  def update
    tick = Time.now.to_i
    if tick - @last_tick > @interval
      @lines.each { |line| line.hide }
      
      msg = `fortune -a`.split("\n")
      
      @font.size = @init_font_size
      
      y = 0
      msg.each_with_index { |line,index|
        line.gsub!("\t","    ")
        line.rstrip!
        line = " " if line.size <= 0
        if @lines[index].nil?
          @lines[index] = Widgets::Label.new(@line.x,y,line,@font)
          add @lines[index]
        else
          @lines[index].font = @font
          @lines[index].string = line
          @lines[index].x = @line.x
          @lines[index].y = y
        end
        y += 1
      
        @lines[index].show true
      }
      
      resize_to_fit(msg.size)

      @last_tick = tick
    end
  end
end
