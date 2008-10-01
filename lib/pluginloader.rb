require 'plugins/plugin'
module Mediabox

class PluginLoader
  attr_accessor :screens
  attr_reader :plugins,:slotless_plugins
  
  def PluginLoader.preferences=(hash)
    @@preferences = hash
  end
  
  def initialize
    @plugins = {}
    @slotless_plugins = {}
    
    Plugin.preferences=@@preferences
    Plugin.loader=self
    
    load("Plugin.graphics",@@preferences["Plugin.graphics"])
    @@preferences.each { |key,value|
      load(key,value) if not key == "Plugin.graphics"
    }
  end
  
  def load(key,value)
    begin
      if key == "Plugin.load"
        if value.include? ","
          list = value.split(",").map { |l| l.strip }
        else
          list = value.split(" ").map { |l| l.strip }
        end
        list.each { |klass|
          Logger.log("Loading plugin *#{klass}")
          require "plugins/#{klass}/#{klass}"
          @slotless_plugins[klass.to_sym] = eval("#{klass}.new")
        }
      elsif key =~ /^Plugin\.(\S+)$/
        slot = $1
        Logger.log("Loading plugin #{slot}:#{value}")
        require "plugins/#{slot}/#{value}/#{value}"
        eval("@plugins[slot.to_sym] = #{value}.new")
      end
    rescue LoadError
      Logger.log("Unable to load plugin #{value} in slot #{key}: #{$!}")
      STDERR.print "Unable to load plugin #{value} in slot #{key}: #{$!}\n"
    end
  end  
  
  def setup
    send_to_all(:setup,true)
  end
  
  def update
    send_to_all(:update)
  end
  
  def close
    send_to_all(:close,true)
  end
  
  def process(msg,log=false)
    @plugins.each { |key,plugin| 
      if plugin.respond_to?(:process)
        Logger.log("Plugin[#{key}].process #{msg}") if log
        return true if plugin.process(msg)
      end
    }
    @slotless_plugins.each { |key,plugin|
      if plugin.respond_to?(:process)
        plugin.process(msg)
        return true if Logger.log("Plugin[#{key}].process #{msg}") if log
      end
    }
    return false
  end
  
  def send_to_all(msg,log=false)
    @plugins.each { |key,plugin| 
      if plugin.respond_to?(msg)
        plugin.send(msg)
        Logger.log("Plugin[#{key}].#{msg}") if log
      end
    }
    @slotless_plugins.each { |key,plugin|
      if plugin.respond_to?(msg)
        plugin.send(msg)
        Logger.log("Plugin[#{key}].#{msg}") if log
      end
    }
  end
  
  def method_missing(sym)
    return @plugins[sym] if @plugins.keys.include? sym
    return @slotless_plugins[sym] if @slotless_plugins.keys.include? sym
    
    throw "No Plugin slot \"#{sym}\"!"
  end
end

end
