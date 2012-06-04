module MIMA

  ##
  # This class implements the MIMA it self
  # for the layout of the Mima see README
  #
  class Mima
    
    ##
    # initialize this with a given number of pipes
    # default 24
    #
    def initialize num_pipes = 24
      @controlunit = MIMA::ControlUnit.new num_pipes
      @akku        = @controlunit.akku
      @iar         = @controlunit.iar
      @one         = @controlunit.one
      @ir          = @controlunit.ir
      @alu         = @controlunit.alu
      @x           = @controlunit.x
      @y           = @controlunit.y
      @z           = @controlunit.z
      @memory      = @controlunit.memory
      @mar         = @controlunit.mar
      @mdr         = @controlunit.mdr
      @bus         = MIMA::Bus.new num_pipes
      @register    = [@akku, @iar, @one, @ir, @x, @y, @z, @mar, @mdr]

      # initialize bus
      @register.each { |r| @bus.add r }
    end

    ##
    # processes one clk
    #
    def clk
      @controlunit.clk
      @bus.clk
      @memory.clk
      @alu.clk
    end

    ##
    # Lets the Mima procress an given command
    #
    def run command
      if command.is_a? String
        command = MIMA::MimaCommand.new command
      elsif command.class != MIMA::MimaCommand
        raise ArgumentError.new "not an MIMA command"
      end

      # load command into instruction register
      @ir.content = command.bits

      # set controlunit of decode
      @controlunit.mip = 0x05

      # run the microprogramm
      clk until @controlunit.mip == 0x00
    end

  end
  

end
