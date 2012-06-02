module MIMA

  ##
  # A IR is a MIMA Bus component.
  # The special thing on an IR (Instruction Register),
  # that you can directly read the OpCode (Most Significant Byte)
  # used by the ControlUnit of the MIMA
  #
  class IR < MIMA::Register
  
    ##
    # initialize this with a given number of pipes
    # default is 24
    #
    def initialize num_pipes = 24
      super "IR", num_pipes
    end

    ##
    # returns the Most Significant Byte of this
    #
    def opcode; @bits[@bits.length - 8, 8]; end

  end

end
