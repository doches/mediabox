require 'plugins/plugin'
require 'lib/widgets'

class BackgroundPlugin < Widgets::Widget
  def BackgroundPlugin.preferences=(pref)
    @@preferences = pref
  end
  
  def BackgroundPlugin.preferences
    @@preferences
  end
  
  def BackgroundPlugin.loader=(loader)
    @@loader = loader
  end
  
  def BackgroundPlugin.loader
    @@loader
  end
end
