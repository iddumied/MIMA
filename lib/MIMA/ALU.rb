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
    # Set control pipe C1
    #
    def c1= c; @c1 = (c == 1) ? 1 : 0; end

    ##
    # Set control pipe C2
    #
    def c2= c; @c2 = (c == 1) ? 1 : 0; end

    ##
    # Returns the currents state of this, depending on the control pipes:
    #
    # C2 C1 C0 | ALU Operation
    # -----------------------------------------
    #  0  0  0 | Z -> Z (do nothing)
    #  0  0  1 | X + Y -> Z
    #  0  1  0 | rotate X right -> Z
    #  0  1  1 | X AND Y -> Z
    #  1  0  0 | X OR Y -> Z
    #  1  0  1 | X XOR Y -> Z
    #  1  1  0 | one complement (NOT) of X -> Z
    #  1  1  1 | if X == Y, -1 -> Z else 0 -> Z
    #
    def state
      case [@c2, @c1, @c0]
        when [0,0,0] then "Z -> Z"
        when [0,0,1] then "X + Y"
        when [0,1,0] then "rotate x"
        when [0,1,1] then "x & y"
        when [1,0,0] then "x | y"
        when [1,0,1] then "x ^ y"
        when [1,1,0] then "~ x"
        when [1,1,1] then "x == y"
        else raise RuntimeError.new "wrong alu operation: #{ [@c2, @c1, @c0] }"
      end
    end

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
    #  1  1  0 | one complement (NOT) of X -> Z
    #  1  1  1 | if X == Y, -1 -> Z else 0 -> Z
    #
    def clk
      case [@c2, @c1, @c0]
        when [0,0,0] then do_nothing;
        when [0,0,1] then x_add_y
        when [0,1,0] then rotate_x
        when [0,1,1] then x_and_y
        when [1,0,0] then x_or_y
        when [1,0,1] then x_xor_y
        when [1,1,0] then not_x
        when [1,1,1] then x_equal_y
        else raise RuntimeError.new "wrong alu operation: #{ [@c2, @c1, @c0] }"
      end
      @z
    end

    ##
    # lets the ALU calulate:
    #
    # Z -> Z (do nothing)
    #
    def do_nothing
      z = @z.content
      @z.content = z
    end

    ##
    # lets the ALU calulate:
    #
    # X + Y -> Z
    #
    def x_add_y
      x = @x.content
      y = @y.content
      z = Array.new @x.length, 0

      carry = 0

      # claulate x + y = z
      @x.length.times do |i|
        tmp   = x[i] + y[i] + carry
        z[i]  = tmp % 2
        carry = tmp / 2
      end

      @z.content = z
    end
    
    ##
    # lets the ALU calulate:
    #
    # rotate X right -> Z
    #
    def rotate_x
      x = @x.content
      z = Array.new @z.length, 0

      @z.length.times { |i| z[i] = x[(i - 1) % @z.length] }

      @z.content = z
    end
    
    ##
    # lets the ALU calulate:
    #
    # X AND Y -> Z
    #
    def x_and_y
      x = @x.content
      y = @y.content
      z = Array.new @z.length, 0

      @z.length.times { |i| z[i] = x[i] & y[i] }

      @z.content = z
    end

    ##
    # lets the ALU calulate:
    #
    # X OR Y -> Z
    #
    def x_or_y
      x = @x.content
      y = @y.content
      z = Array.new @z.length, 0

      @z.length.times { |i| z[i] = x[i] | y[i] }

      @z.content = z
    end

    ##
    # lets the ALU calulate:
    #
    # X XOR Y -> Z
    #
    def x_xor_y
      x = @x.content
      y = @y.content
      z = Array.new @z.length, 0

      @z.length.times { |i| z[i] = x[i] ^ y[i] }

      @z.content = z
    end

    ##
    # lets the ALU calulate:
    #
    # one complement of X -> Z
    # ( NOT X -> Z )
    #
    def not_x
      x = @x.content
      z = Array.new @z.length, 0

      @z.length.times { |i| z[i] = (x[i] == 1) ? 0 : 1 } 

      @z.content = z
    end

    ##
    # lets the ALU calulate:
    #
    # if X == Y, -1 -> Z else 0 -> Z
    #
    def x_equal_y
      x = @x.content
      y = @y.content
      z = Array.new @z.length, 1

      @z.length.times do |i|
        unless x[i] == y[i]
          z = Array.new @z.length, 0
          break
        end
      end

      @z.content = z
    end

  end

end
