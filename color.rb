# Now i finally get how the ANSI colors work!
# So this is just a convenience class to return some colorized strings
# Resources: 
#   http://kpumuk.info/ruby-on-rails/colorizing-console-ruby-script-output/
#   http://stackoverflow.com/questions/1489183/colorized-ruby-output
#   http://en.wikipedia.org/wiki/ANSI_escape_code
#   the assembled strings look like this:  "\033[31;47mK#{YOUR TEXT HERE}\033[0m"
class Color
  ESC = "\e["  # same as "\033["
  FG_RED = 31
  FG_BLUE = 34
  FG_BLACK = 30
  FG_WHITE = 37
  BG_BLACK = 40
  BG_WHITE = 47
  OFF = 0
  BRIGHT_MODE = 1
  NORMAL_MODE = ""
  
  # red on white
  def self.red(str)
    str = "#{ESC}#{BRIGHT_MODE};#{FG_RED};#{BG_WHITE}m#{str}#{ESC}#{OFF}m"
  end
  
  # black on white
  def self.black(str)
    str = "#{ESC}#{BRIGHT_MODE};#{FG_BLACK};#{BG_WHITE}m#{str}#{ESC}#{OFF}m"
  end
   
  # note black in bright mode or white in normal mode is supposed to be gray
  # but neither of those seem to be working for the background... 
  def self.blue(str)
    str = "#{ESC}#{BRIGHT_MODE};#{FG_BLUE};#{BG_WHITE}m#{str}#{ESC}#{OFF}m"
  end
  
end