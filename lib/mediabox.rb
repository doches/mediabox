require 'lib/prefloader'
require 'lib/pluginloader'
require 'lib/screenloader'
require 'lib/messages'
require 'lib/widgets'
require 'lib/logger'

module Mediabox

class Mediabox
  PreferencesFile = "mediabox.conf"
  
  def initialize  
    @preferences = PreferencesLoader.new(PreferencesFile)
    PluginLoader.preferences = @preferences
    ScreenLoader.preferences = @preferences
    Logger.preferences = @preferences
    Logger.instance
    
    @plugins = PluginLoader.new
    @graphics = @plugins.graphics
    @graphics.setup
    Widgets::Widget.graphics=@graphics
    @events = @plugins.events
    

    @screens = ScreenLoader.new(@plugins)
    @plugins.screens = @screens
    @plugins.setup
    @screens.load
  end
  
  def start      
    catch(:quit) do
      loop do
        @events.each { |event|
          case event
            when Messages::Redraw
              @graphics.redraw
            when Messages::Quit
              throw :quit
            else
              if not event.nil?
                if not @screens.current.process(event)
                  @plugins.process(event)
                end
              end
          end
        }
        
        @plugins.update
        @screens.current.update
        @graphics.draw(@screens.current)
      end
    end
  end
    
  def stop
    @plugins.close
#    @screens.close
  end
end

end
