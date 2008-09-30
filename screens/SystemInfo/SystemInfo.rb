require 'screens/screen'
require 'lib/widgets'

class SystemInfo < Screen
  Interval = 5

  def initialize
    super
    
    # Font
    font = Widgets::Font.new("Courier New.ttf",16)
    font.color = [255,255,255]
    
    # Labels
    @labels = ["IP Address","Hostname","Framerate","CPU Usage","Mem Usage","Started","Uptime","Load Average(s)"]
    @labels.each_with_index { |str,i|
      @labels[i] = Widgets::Label.new(10,i,"#{str}: ",font)
    }
    label_height = @labels[0].h + 1
    max_w = 0
    @labels.each_with_index { |label,i| 
      label.y = i*label_height
      max_w = label.w if label.w > max_w
      add label
    }
    max_w += 10
    
    # Information
    @stats = {}
    @stats[:ip] = Widgets::Label.new(max_w,@labels[0].y,"?",font)
    begin
      `ifconfig #{preferences['SystemInfo.interface']}`.reject { |l| not l.include?("inet ") }[0] =~ /(\d+\.\d+\.\d+\.\d+)/
      @stats[:ip].string = $1
    rescue
      @stats[:ip].string = `hostname`.strip
    end
    
    @stats[:hostname] = Widgets::Label.new(max_w,@labels[1].y,`hostname`.strip,font)
    
    offset = 2
    dynamic = [:framerate,:cpu,:mem,:start,:uptime,:loadavg]
    dynamic.each_with_index { |sym,i| 
      @stats[sym] = Widgets::Label.new(max_w,@labels[i+offset].y,"0",font)
    }
    
    @stats.each { |id,label| add(label) }
    
    @tick = Time.now.to_i - Interval - 1
  end
  
  def process(msg)
    ; # Do nothing.
  end
  
  def update
    tock = Time.now.to_i
    sleep(Interval - (tock - @tick)) if tock - @tick <= Interval
    @tick = tock
    ps = `ps -p #{Process.pid} -o pcpu,pmem,start`.split("\n")
    ps = ps[1].strip.split(/\s+/)
    cpu = ps[0]
    mem = ps[1]
    start = ps[2]
    
    @stats[:start].string = start if not @stats[:start].string == start
    @stats[:mem].string = mem if not @stats[:mem].string == mem
    @stats[:cpu].string = cpu if not @stats[:cpu].string == cpu
    
    # Framerate
    framerate = Screen.loader.plugins.graphics.framerate.to_s
    @stats[:framerate].string = framerate if not framerate == @stats[:framerate].string
    
    # Uptime
    begin
    uptime = `uptime`.split(/,/)
    uptime.map! {|l| l.strip}
    uptime[0] = uptime[0].split("up")[1].strip
    @stats[:uptime].string = uptime[0] if not @stats[:uptime].string == uptime[0]
    uptime[3] = uptime[3].split(": ")[1].strip
    @stats[:loadavg].string = uptime[3] if not @stats[:loadavg].string == uptime[3]
    rescue
      ;
    end

    if preferences["SystemInfo.background"] == "true" and Screen.loader.plugins.background
      Screen.loader.plugins.background.color = [(cpu.to_f/100)*255,0,0]
    end
  end
end
