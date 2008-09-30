require 'rubygems'
require 'rubygame'
require 'plugins/events/eventsplugin'

class SDLEvents < EventsPlugin
  include Rubygame
  
  def initialize
    @queue = EventQueue.new
    @queue.ignore = [MouseMotionEvent,KeyUpEvent,MouseDownEvent,MouseUpEvent]
  end
  
  def translate(sdl_event)
    case sdl_event
      when ActiveEvent
        return Messages::Redraw
      when QuitEvent
        return Messages::Quit
      when KeyDownEvent
        case sdl_event.key
          when K_ESCAPE
            return Messages::Quit
        end
    end
  end
  
  def each(&blk)
    @queue.each { |event| blk.call( translate(event) ) }
  end
  
  def add_to_queue(message)
    @queue.post message
  end
end
