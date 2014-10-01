# Now i finally get how the ANSI colors work!
# This is a convenience class to return colorized strings
# Resources: 
#   http://kpumuk.info/ruby-on-rails/colorizing-console-ruby-script-output/
#   http://stackoverflow.com/questions/1489183/colorized-ruby-output
#   http://en.wikipedia.org/wiki/ANSI_escape_code
class Color
  ESC = "\e["  # same as "\033["
  FG_RED = 31
  FG_BLACK = 30
  FG_WHITE = 37
  BG_WHITE = 47
  OFF = 0
  BRIGHT_MODE = 1
  NORMAL_MODE = ""
  
  # instead of constants, maybe use a hash for all the color values
  # COLORS = {text: {red: 31, black: 30, ...}, background: {white: 47, red: xx, ...}}
  # str =  "#{ESC}#{1};#{COLORS.text.red};#{COLORS.background.white}m#{str}#{ESC}#{OFF}m"
  
  def self.red(str)
    # red on white
    str = "#{ESC}#{NORMAL_MODE};#{FG_RED};#{BG_WHITE}m#{str}#{ESC}#{OFF}m"
  end
  
  def self.black(str)
    str = "#{ESC}#{NORMAL_MODE};#{FG_BLACK};#{BG_WHITE}m#{str}#{ESC}#{OFF}m"
  end
  
end

# puts "\033[0"
# ee = "\033[0m"
# ee = "\033[31;47mK\u2667 \033[0m"