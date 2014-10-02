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
end #Util