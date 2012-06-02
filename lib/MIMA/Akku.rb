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
    # initialize this with a given number of pipes
    # default is 24
    #
    def initialize num_pipes = 24
      super "Akku", num_pipes
    end

    ##
    # returns the MBS (most Significant Bit) of this
    # which indicates wheter the Akku content is negative or positive
    #
    def msb; @bits[@bits.length - 1]; end

  end

end
