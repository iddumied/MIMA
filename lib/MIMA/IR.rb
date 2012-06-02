module MIMA

  ##
  # A IR is a MIMA Bus component.
  # The special thing on an IR (Instruction Register),
  # that you can directly read the OpCode (Most Significant Byte)
  # used by the ControlUnit of the MIMA
  #
  class IR < MIMA::Register
  
    ##
    # returns the Most Significant Byte of this
    #
    def opcode; @bits[@bits.length - 8, 8]; end

  end

end
