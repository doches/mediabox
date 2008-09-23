require 'singleton'

module Mediabox

class Logger
  include Singleton
  
  def Logger.preferences=(pref)
    @@preferences = pref
  end
  
  def initialize
    setup
  end
  
  def setup
    file = @@preferences["Logger.file"]
    file ||= @@preferences["Logger.logfile"]
    file ||= "stderr" # Default to STDERR
    if file.downcase == "stderr"
      @@file = STDERR
    elsif file.downcase == "stdout"
      @@file = STDOUT
    else
      @@file = File.open( file, "w")
    end
  end
  
  def log(message)
    Logger.log(message)
  end
  
  def Logger.log(message)
    setup if @@file.nil?
    @@file.print(message.strip, "\n")
  end
end

end
