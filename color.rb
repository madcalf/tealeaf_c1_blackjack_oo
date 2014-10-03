# Now i finally get how the ANSI colors work!
# So this is just a convenience class to return some colorized strings
# Resources: 
#   http://kpumuk.info/ruby-on-rails/colorizing-console-ruby-script-output/
#   http://stackoverflow.com/questions/1489183/colorized-ruby-output
#   http://en.wikipedia.org/wiki/ANSI_escape_code
#   the assembled strings look like this:  "\033[31;47mK#{YOUR TEXT HERE}\033[0m"
class Color
  ESC = "\e["  # same as "\033["
  OFF = 0
  BRIGHT_MODE = 1
  NORMAL_MODE = ""
  BLACK = 0
  RED = 1
  GREEN = 2
  YELLOW = 3
  BLUE = 4
  MAGENTA = 5
  CYAN = 6
  WHITE = 7
  HIDDEN = 8
  BG_OFFSET = 40
  FG_OFFSET = 30
      
  def self.colorize(str, fg, bg = nil, bright = true)
    mode = bright ? BRIGHT_MODE : NORMAL_MODE
    bg = (bg == nil) ? nil : bg + BG_OFFSET
    fg = (fg == HIDDEN) ? HIDDEN : fg + FG_OFFSET
    if bg
      str = "#{ESC}#{mode};#{fg};#{bg}m#{str}#{ESC}#{OFF}m"
    else
      str = "#{ESC}#{mode};#{fg}m#{str}#{ESC}#{OFF}m"
    end
  end

  def self.red(str, bg = nil, bright = true)
    self.colorize(str, RED, bg, bright)
  end 
  
  def self.red_white(str, bright = true)
    self.colorize(str, RED, WHITE, bright)
  end
  
  def self.black(str, bg = nil, bright = true)
    self.colorize(str, BLACK, bg, bright)
  end 
  
  def self.black_white(str, bright = true)
    self.colorize(str, BLACK, WHITE, bright)
  end
    
  def self.green(str, bg = nil, bright = true)
    self.colorize(str, GREEN, bg, bright)
  end 
  
  def self.green_white(str, bright = true)
    self.colorize(str, GREEN, WHITE, bright)
  end
      
  def self.yellow(str, bg = nil, bright = true)
    self.colorize(str, YELLOW, bg, bright)
  end 
  
  def self.yellow_white(str, bright = true)
    self.colorize(str, YELLOW, WHITE, bright)
  end       
  
  def self.blue(str, bg = nil, bright = true)
    self.colorize(str, BLUE, bg, bright)
  end 
  
  def self.blue_white(str, bright = true)
    self.colorize(str, BLUE, WHITE, bright)
  end
  
  # # white on white (hidden text on white card)
  # def self.blank(str)
  #   str = "#{ESC}#{BRIGHT_MODE};#{HIDDEN_TEXT};#{BG_WHITE}m#{str}#{ESC}#{OFF}m"
  # end
  
end