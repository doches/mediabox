require 'plugins/plugin'
require 'lib/messages'

class EventsPlugin < Plugin
  def translate(message)
    throw :not_implemented
  end
  
  def each(&blk)
    throw :not_implemented
  end
  
  def add_to_queue(message)
    throw :not_implemented
  end
end
