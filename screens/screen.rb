class Screen

  # Screens should implement this method to handle messages.
  def process(msg)
    throw :not_implemented
  end
  
  # Screens should implement this method to update their state every tick.
  def update
    throw :not_implemented
  end
  
  # Screens should call super() during initialization.
  def initialize
    @drawlist = []
    begin
      @drawlist.push @@loader.plugins.background
    rescue
      ; # No background plugin loaded
    end
  end
  
  def add(widget)
    @drawlist.push widget
  end
  
  def remove(widget)
    @drawlist.reject! {|x| x == widget}
  end
  
  def drawlist
    return @drawlist
  end
  
  def Screen.preferences=(pref)
    @@preferences = pref
  end
  
  def Screen.preferences
    @@preferences
  end
  
  def preferences
    @@preferences
  end
  
  def loader
    @@loader
  end
  
  def send_message(message)
    @@loader.plugins.events.add_to_queue(message)
  end
  
  def Screen.loader=(loader)
    @@loader = loader
  end
  
  def Screen.loader
    @@loader
  end
  
  def Screen.switch_to(screen)
    @@loader.switch_to(screen)
  end
  
  def Screen.back
    @@loader.back
  end
end
