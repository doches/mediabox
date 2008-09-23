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

class RecentTracks < Screen
  def initialize
    super
    
    # Get background plugin so we can swap out bg color.
    @bg = Screen.loader.plugins.background
    
    # Labels
    font = Widgets::Font.new("trebuc.ttf",48)
    font.color=[64,64,64]
    artist_font = Widgets::Font.new("trebuc.ttf",24)
    artist_font.color=[128,128,128]
    @labels = []
    y = 0
    color = [255,255,255]
    index = 1
    10.times do 
      index += 1
      
      track = Widgets::Label.new(10,y,"Loading...",font)
      date = Widgets::Label.new(0,y," ",artist_font)
      y += track.h
      
      artist = Widgets::Label.new(10,y,"Loading...",artist_font)
      y += artist.h + 5
      
      add(track)
      add(date)
      add(artist)
      @labels.push( { :track => track, :artist => artist, :date => date })

      color = (color[0] == 255 ? [220,220,220] : [255,255,255])
    end
    lineheight = @labels[0][:track].h + @labels[0][:artist].h
    start_height = preferences['Video.height'] - lineheight * @labels.size
    @labels.each do |hash|
      hash[:track].y = start_height
      hash[:date].y = start_height + 4
      hash[:artist].y = hash[:track].y + hash[:track].h - 5
      start_height = hash[:artist].y + hash[:artist].h + 5
    end
    
    # AS icon & header
    @icon = Widgets::Image.new(0,15,"audioscrobbler.png")
    @icon.x = preferences['Video.width'] - @icon.w - 15
    rect = Widgets::Rect.new(0,0,preferences['Video.width'],@icon.y + @icon.h - 32,[196,196,196])
    line = Widgets::Rect.new(0,rect.h,preferences['Video.width'],1,[128,128,128])
    header_font = Widgets::Font.new("trebuc.ttf",64)
    header_font.color = [96,96,96]
    header_font2 = Widgets::Font.new("trebuc.ttf",64)
    header_font2.color = [128,128,128]
    header = Widgets::Label.new(10,10,"Recent",header_font)
    header2 = Widgets::Label.new(10,10,"Tracks",header_font2)
    header.x = preferences['Video.width']/2 - (header.w + header2.w)/2
    header2.x = header.x + header.w
    add( rect )
    add( line )
    add( header )
    add( header2 )
    
    add @icon
    
    @last_tick = Time.now.to_i
    @interval = preferences['RecentTracks.interval']
    @interval = (@interval.nil? ? 240 : @interval.to_i) # Default to 4 minutes
    
    # Get Audioscrobbler data for user    
    Thread.new {
      show_tracks
    }
  end

  def show_tracks
    return if @working
    @working = true
    now = Time.now
    Scrobbler::User.new(preferences['RecentTracks.username']).recent_tracks.each_with_index do |track,i|
      break if i >= 10
      @labels[i][:track].string = track.name.unescape
      @labels[i][:artist].string = track.artist.unescape
      diff = now - (track.date + track.date.gmt_offset)
      @labels[i][:date].string = seconds_to_str(diff.to_i)
      @labels[i][:date].x = preferences['Video.width'] - @labels[i][:date].w - 10
    end
    @working = false
  end
  
  def seconds_to_str(n)
    seconds = n
    minutes = (seconds / 60)
    hours = (minutes / 60)
    days = (hours / 24)
    
    if seconds <= 60
      return "#{seconds} second#{seconds != 1 ? 's' : ''} ago"
    elsif minutes <= 60
      return "#{minutes} minute#{minutes != 1 ? 's' : ''} ago"
    elsif hours <= 24
      return "#{hours} hour#{hours != 1 ? 's' : ''} ago"
    elsif days <= 7
      return "#{days} day#{days != 1 ? 's' : ''} ago"
    else
      return "over a week ago"
    end
  end
  
  def on_focus
    @old_bg_color = @bg.color
    @bg.color = [255,255,255]
  end
  
  def lose_focus
    @bg.color = @old_bg_color
  end
  
  def process(msg)
    # do nothing
  end
  
  def update
    tick = Time.now.to_i
    if tick - @last_tick > @interval
      @last_tick = tick
      
      Thread.new { show_tracks }
    end
  end
end
