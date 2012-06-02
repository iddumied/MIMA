module MIMA

  ##
  # A Akku is a MIMA Bus component.
  # The special thing on an Akku Register is,
  # that you can directly read the MSB 
  # what menas you know wheter the Akku is 
  # smaler zero or greater
  #
  class Akku < MIMA::Register
  
    ##
    # returns the MBS (most Significant Bit) of this
    # which indicates wheter the Akku content is negative or positive
    #
    def msb; @bits[@bits.length - 1]; end

  end

end
