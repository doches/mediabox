require 'screens/screen'
require 'lib/widgets'
require 'scrobbler'

class String
  def unescape
    string = self
    str = string.dup
    str.gsub!(/&(.*?);/n) {
      match = $1.dup
      case match
        when /\Aamp\z/ni           then '&'
        when /\Aquot\z/ni          then '"'
        when /\Agt\z/ni            then '>'
        when /\Alt\z/ni            then '<'
        when /\A#(\d+)\z/n         then Integer($1).chr
        when /\A#x([0-9a-f]+)\z/ni then $1.hex.chr
      end
    }
    return str
  end
end  

class TopAlbums < Screen
  def initialize
    super
    
    @bg = Screen.loader.plugins.background
    
    # update interval
    @interval = preferences['TopAlbums.interval']
    @interval = (@interval.nil? ? 15 : @interval.to_i)
    @last_tick = Time.now.to_i
    
    # AS icon
    @icon = Widgets::Image.new(0,15,"audioscrobbler.png")
    @icon.x = preferences['Video.width'] - @icon.w - 15
    
    # Get Audioscrobbler data for user
    @user = Scrobbler::User.new(preferences['TopAlbums.username'])
    
    @images = []
    @extras = []
    @extra_index = 0
    Thread.new {
      show_albums
      add @icon
    }
  end
  
  def show_albums
    x,y = 0,0
    albums = @user.top_albums
    lineheight = 0
    albums.each do |album|
      url = album.image_large
      url =~ /([^\/]*)$/
      file = $1
      path = File.join("screens","TopAlbums","resources","cache",file)
      if not File.exists?(path)
        Mediabox::Logger.log("Downloading album art for #{album.name}")
        `wget #{url} --output-document=#{path}`
      end
      image = Widgets::Image.new(x,y,File.join("cache",file))
      x += image.w
      if x >= preferences['Video.width']
        y += lineheight
        x = 0
        lineheight = 0
      end
      if y >= preferences['Video.height']
        @extras.push image
      else
        add(image)
        @images.push image
        lineheight = image.h if image.h > lineheight
      end
    end
  end

  def update
    tick = Time.now.to_i
    if tick - @last_tick > @interval and not @extras.empty?
      @last_tick = tick
      index= rand * (@images.size-1)
      temp = @images[index].store
      @images[index].store = @extras[@extra_index].store
      @extras[@extra_index].store = temp
      @extra_index += 1
      @extra_index = 0 if @extra_index >= @extras.size
      @images[index].change!
    end
  end
  
  def on_focus
    @old_bg_color = @bg.color
    @bg.color = [255,255,255] 
  end
  
  def lose_focus
    @bg.color = @old_bg_color
  end
end
