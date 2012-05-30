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
      @x = MIMA::Register.new "X", num_pipes
      @y = MIMA::Register.new "Y", num_pipes
      @z = MIMA::Register.new "Z", num_pipes
      @c0 = @c1 = @c2 = 0
    end

    attr_reader :x, :y, :z

    ##
    # Set control pipe C0
    #
    def c0= c; @c0 = (c == 1) ? 1 : 0; end

    ##
    # Set control pipe C2
    #
    def c2= c; @c2 = (c == 1) ? 1 : 0; end

    ##
    # Set control pipe C2
    #
    def c2= c; @c2 = (c == 1) ? 1 : 0; end

    ##
    # depending on the control pipes it calculases:
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
    def clk
      case [@c2, @c1, @c0]
        when [0,0,0] then do_nothing; true
        when [0,0,1] then x_add_y;    true
        when [0,1,0] then rotate_x;   true
        when [0,1,1] then
        when [1,0,0] then
        when [1,0,1] then
        when [1,1,0] then
        when [1,1,1] then
        else false
      end
    end

    ##
    # lets the ALU calulate:
    #
    # Z -> Z (do nothing)
    #
    def do_nothing
      @z.write = 1
      @z.read  = 0
      z = z.bus_write

      @z.write = 0
      @z.read  = 1
      @z.bus_read z

      @z.read  = 0
    end

    ##
    # lets the ALU calulate:
    #
    # X + Y -> Z
    #
    def x_add_y
      @x.write = 1
      @x.read  = 0
      @y.write = 1
      @y.read  = 0

      x = @x.bus_write
      y = @y.bus_write
      z = Array.new @x.length, 0

      carry = 0

      # claulate x + y = z
      for i in (0...@x.length) do
        tmp   = x[i] + y[i] + carry
        z[i]  = tmp % 2
        carry = tmp / 2
      end

      @x.write = 0
      @y.write = 0
      @z.write = 0
      @z.read  = 1
      @z.bus_read z

      @z.read = 0
    end
    
    ##
    # lets the ALU calulate:
    #
    # rotate X right -> Z
    #
    def rotate_x
      @x.write = 1
      @x.read  = 0
      @z.write = 0
      @z.read  = 1

      x = @x.bus_write
      z = Array.new @z.length, 0
      @x.write = 0

      for i in (0..@z.length) do
        z[i] = x[(i - 1) % @z.length]
      end
      
      @z.bus_read z
      @z.read = 0
    end
    
    ##
    # lets the ALU calulate:
    #
    # X AND Y -> Z
    #
    def x_and_y
      @x.read  = 0
      @x.write = 1
      @y.read  = 0
      @y.write = 1
      @z.read  = 1
      @z.write = 0

      x = @x.bus_write
      y = @y.bus_write
      z = Array.new @z.length, 0

      for i in (0...@z.length) do
        z[i] = x[i] & y[i]
      end

      @z.bus_read z
      @z.read = 0
    end

    ##
    # lets the ALU calulate:
    #
    # X OR Y -> Z
    #
    def x_or_y
      @x.read  = 0
      @x.write = 1
      @y.read  = 0
      @y.write = 1
      @z.read  = 1
      @z.write = 0

      x = @x.bus_write
      y = @y.bus_write
      z = Array.new @z.length, 0

      for i in (0...@z.length) do
        z[i] = x[i] | y[i]
      end

      @z.bus_read z
      @z.read = 0
    end

    ##
    # lets the ALU calulate:
    #
    # X XOR Y -> Z
    #
    def x_xor_y
      @x.read  = 0
      @x.write = 1
      @y.read  = 0
      @y.write = 1
      @z.read  = 1
      @z.write = 0

      x = @x.bus_write
      y = @y.bus_write
      z = Array.new @z.length, 0

      for i in (0...@z.length) do
        z[i] = x[i] ^ y[i]
      end

      @z.bus_read z
      @z.read = 0
    end

  end

end