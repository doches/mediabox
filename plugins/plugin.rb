class Plugin
  def Plugin.preferences=(pref)
    @@preferences = pref
  end
  
  def Plugin.preferences
    @@preferences
  end
  
  def Plugin.loader=(loader)
    @@loader = loader
  end
  
  def Plugin.loader
    @@loader
  end
  
  # Optional
  def setup
  
  end
end
