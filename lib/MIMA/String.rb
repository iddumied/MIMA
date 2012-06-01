class String

  ##
  # converts an hex String "0x*" into A Binary Array
  #
  def hex_to_bin
    ary = []
    self.split("x").last.upcase.each_char do |c|
      case c
        when "0" then ary = [0,0,0,0] + ary
        when "1" then ary = [1,0,0,0] + ary
        when "2" then ary = [0,1,0,0] + ary
        when "3" then ary = [1,1,0,0] + ary
        when "4" then ary = [0,0,1,0] + ary
        when "5" then ary = [1,0,1,0] + ary
        when "6" then ary = [0,1,1,0] + ary
        when "7" then ary = [1,1,1,0] + ary
        when "8" then ary = [0,0,0,1] + ary
        when "9" then ary = [1,0,0,1] + ary
        when "A" then ary = [0,1,0,1] + ary
        when "B" then ary = [1,1,0,1] + ary
        when "C" then ary = [0,0,1,1] + ary
        when "D" then ary = [1,0,1,1] + ary
        when "E" then ary = [0,1,1,1] + ary
        when "F" then ary = [1,1,1,1] + ary
        else raise ArgumentError.new("Not a hex number: #{ addr[i] }")
      end

    end

    ary
  end


end
