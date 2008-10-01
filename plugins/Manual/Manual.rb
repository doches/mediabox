require 'plugins/plugin'

class Manual < Plugin
  def setup
    return false if Plugin.loader.screens.screenlist.empty?
    @list = Plugin.loader.screens.screenlist
    @current = @list.index("#{Plugin.loader.screens.current.class}".to_sym)
    @current ||= 0
    return true
  end
  
  def process(msg)
    if @list.nil?
      return false if not setup
    end
    case msg
      when Messages::Left
        @current -= 1
        @current = @list.size-1 if @current < 0
        Plugin.loader.screens.switch_to(@list[@current])
        return true
      when Messages::Right
        @current += 1
        @current = 0 if @current > @list.size-1
        Plugin.loader.screens.switch_to(@list[@current])
        return true
    end
    return false
  end
end
