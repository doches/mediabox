require 'plugins/plugin'

class Rotate < Plugin
  def setup
    @tick = Time.now.to_i
    @interval = Plugin.preferences['Rotate.interval'].to_i
    @interval ||= 5
    @list = Plugin.loader.screens.screenlist
    @current = @list.index("#{Plugin.loader.screens.current.class}".to_sym)
    @current ||= 0
  end
  
  def update
    tock = Time.now.to_i
    if tock - @tick > @interval
      @tick = tock
      @current += 1
      @current = 0 if @current >= @list.size
      Plugin.loader.screens.switch_to(@list[@current])
    end
  end
end
