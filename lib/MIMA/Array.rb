class Array

    ##
    # converts an binary Array to its dezimal represenation
    #
    def bin_to_dez
      dez = 0
      self.each_with_index do |e, i|
        dez += e * 2**i
      end

      dez
    end

    ##
    # converts a binary Array to its hex representation
    #
    def bin_to_hex
      hex = ""

      for i in (0...(self.length/4) do
        case self[i * 4, 4]
          when [0,0,0,0] then hex += "0"
          when [1,0,0,0] then hex += "1"
          when [0,1,0,0] then hex += "2"
          when [1,1,0,0] then hex += "3"
          when [0,0,1,0] then hex += "4"
          when [1,0,1,0] then hex += "5"
          when [0,1,1,0] then hex += "6"
          when [1,1,1,0] then hex += "7"
          when [0,0,0,1] then hex += "8"
          when [1,0,0,1] then hex += "9"
          when [0,1,0,1] then hex += "A"
          when [1,1,0,1] then hex += "B"
          when [0,0,1,1] then hex += "C"
          when [1,0,1,1] then hex += "D"
          when [0,1,1,1] then hex += "E"
          when [1,1,1,1] then hex += "F"
        end
      end

      hex += "x0"
      hex.reverse
    end

end
