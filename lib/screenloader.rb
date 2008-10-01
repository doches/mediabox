require 'screens/screen.rb'

module Mediabox

class ScreenLoader
  def ScreenLoader.preferences=(hash)
    @@preferences = hash
  end
  
  def ScreenLoader.plugins=(loader)
    @@plugins = loader
  end
  
  def plugins
    @@plugins
  end
  
  def preferences
    @@preferences
  end
  
  def initialize(plugins=nil)
    @@plugins = plugins if not plugins.nil?
    @autoload_dirs = []
    
    Screen.preferences=@@preferences
    Screen.loader=self 
    
    @current = nil
    @screens = {}
    @history = []
  end
  
  def load
    @@preferences.each { |key,value|
      if key == "Screen.load"
        screens = (value.include?(",") ? value.split(",") : value.split(" "))
        screens.each { |screen|
          screen.strip!
          Logger.log("Loading screen #{screen}")
          autoload_dir = File.join("screens",screen,"resources")
          @autoload_dirs.push autoload_dir if File.exists?(autoload_dir)
          require "screens/#{screen}/#{screen}"
          eval("@screens[screen.to_sym] = #{screen}.new")
          @current ||= screen.to_sym
        }
      elsif key == "Screen.start"
        @current = value.strip.to_sym
      end
    }
    @current = @screens[@current.to_sym]
    @current.on_focus if @current.respond_to?(:on_focus)
  end
  
  def screenlist
    @screens.keys
  end
  
  def autoload_dirs
    @autoload_dirs
  end
  
  def current
    @current
  end
  
  def switch_to(screen)
    if not @screens.include?(screen)
      Logger.log("Screen #{screen} not found -- called by #{@current}")
      return false
    end
    screen = @screens[screen]
    @history.push @current
    @current.lose_focus if @current.respond_to?(:lose_focus)
    @current = screen
    screen.on_focus if screen.respond_to?(:on_focus)
    
    @current.drawlist[0].change! if @current.drawlist[0].respond_to?(:change!)
    return true
  end
  
  def back
    if not @history.empty?
      @current.lose_focus if @current.respond_to?(:lose_focus)
      @current = @history.pop
      @current.on_focus if @current.respond_to?(:on_focus)
      @current.drawlist[0].change! if @current.drawlist[0].respond_to?(:change!)
    end
  end
end

end
