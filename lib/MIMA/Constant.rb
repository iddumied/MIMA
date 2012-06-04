module MIMA

  ##
  # A Constante is a MIMA Bus component.
  # A Constante can onely write its initial content to the Bus
  #
  class Constant < MIMA::Register
    
    ##
    # initialize this with a given name and number of pipes
    # it can read or write (default 24).
    # If the buss containes more pipes it onely read an writes 
    # the last significant pipes.
    #
    def initialize name, bits
      super name, bits.length
      @bits = bits
      @write = 0
    end

    ##
    # just implementet to prevent errors
    #
    def bus_read val
      "Constants can not read from the Bus"
    end

    ##
    # One line description of this
    #
    def inspect
      str = "#<MIMA::Constant bits="

      @bits.reverse.each { |b| str += b.to_s }
      str += " write=#{ @write } name=#{ @name }>"
    end

    ##
    # Returns a detailed describtion of this
    #
    def describe
      str = "MIMA::Constant #{ @name } write(#{ @write })\nBits: "
      @bits.reverse.each { |b| str += b.inspect }
      str += "\n"
    end
    
  end

end
