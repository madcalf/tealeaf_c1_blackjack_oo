class Util
  
  # test if unicode support is available 
  # found the ENV test here: http://rosettacode.org/wiki/Terminal_control/Unicode_output#Ruby 
  def self.unicode_supported?
    values = ENV.values_at("LC_ALL","LC_CTYPE","LANG").compact
    # note: array is empty if none of these environment vars are found
    return false if values.size == 0 
    values.first.include?("UTF-8")
  end  
  
  # this Float test is common on SO
  def self.numeric?(str) 
    begin 
      result = Float(str) ? true : false
    rescue
      result = false
    ensure
      return result
    end
  end    

  # got the RbConfig.. ['host_os'] from here:
  # https://github.com/markryall/splat/blob/master/lib/splat.rb
  def self.windows?
    win_platforms = ["mswin", "win32", "dos", "cygwin", "mingw"]
    current_os = RbConfig::CONFIG['host_os']
    puts "current_os: #{current_os}"
    win_platforms.select { |win| current_os.include?(win) }.size > 0
  end
  
  def self.clear_screen
    if self.windows?
      system 'cls'
    else
      system 'clear'
    end
  end
end #Util
