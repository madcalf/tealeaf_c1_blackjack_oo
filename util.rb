class Util
  def self.numeric?(str) 
    begin 
      result = Float(str) ? true : false
    rescue
      result = false
    ensure
      return result
    end
  end    
end