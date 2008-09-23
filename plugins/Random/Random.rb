require 'plugins/plugin'

class Random < Plugin
  def setup
    @tick = Time.now.to_i
    @interval = Plugin.preferences['Random.interval'].to_i
    @interval ||= 5
    @list = Plugin.loader.screens.screenlist
    @current = @list.index("#{Plugin.loader.screens.current.class}".to_sym)
  end
  
  def update
    tock = Time.now.to_i
    if tock - @tick > @interval
      @tick = tock
      @current = rand * @list.size
      Plugin.loader.screens.switch_to(@list[@current])
    end
  end
end
