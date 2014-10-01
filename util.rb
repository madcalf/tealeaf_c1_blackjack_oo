class Util
  
  # test if unicode support is available 
  # found this test here: http://rosettacode.org/wiki/Terminal_control/Unicode_output#Ruby 
  def self.unicode_supported?
    ENV.values_at("LC_ALL","LC_CTYPE","LANG").compact.first.include?("UTF-8")
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