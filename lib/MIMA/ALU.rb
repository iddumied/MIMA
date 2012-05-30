module MIMA

  ##
  # This class Implements the ALU (Arithmetic Logic Unit) of the MIMA
  # ALU has three control pipes an provides 8 operations:
  #
  # C2 C1 C0 | ALU Operation
  # -----------------------------------------
  #  0  0  0 | Z -> Z (do nothing)
  #  0  0  1 | X + Y -> Z
  #  0  1  0 | rotate X right -> Z
  #  0  1  1 | X AND Y -> Z
  #  1  0  0 | X OR Y -> Z
  #  1  0  1 | X XOR Y -> Z
  #  1  1  0 | one complement of X -> Z
  #  1  1  1 | if X == Y, -1 -> Z else 0 -> Z
  #
  class ALU

    ##
    # Initialize this with given pipe length
    # default is 24
    #
    def initialize num_pipes = 24

    end

  end

end
