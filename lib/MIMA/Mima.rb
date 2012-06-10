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

    attr_reader :controlunit, :akku, :ira, :one, :ir, :alu, :x, :y, :z, :memory, :mar, :mdr, :bus, :register

    ##
    # processes one clk
    #
    def clk
      [ @controlunit, @bus, @memory, @alu ].each { |o| o.clk }
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

    ##
    # Implements a Shell for the MIMA to play with it
    # you can use all MIMA comands plus som aditional commands:
    #
    # command      | description
    # -------------+------------
    # e, exit      | exits this shell
    # q, quit      | exits this shell
    # h, help      | prints an help overview
    # p, print <r> | prints the content of register <r>
    #
    def sh prompt = "mima ~> "
      print prompt
      input = gets.chop

      until ["e", "q", "exit", "quit"].include? input.downcase
        args = input.split " "
        
        if ControlUnit::MICROPROGRAMMS[args.first] != nil
          run input

        elsif ["p", "print"].include? args.first.downcase
          sh_print args

        end

        print prompt
        input = gets.chop
      end
      
    end

    ##
    # processes an shell print command
    #
    def sh_print args

      # prints ALU state
      if args.include? "ALU" or args.include? "alu"
        puts "ALU: #{ @alu.state }"
        args.delete("alu")
        args.delete("ALU")
      end

      # prints value at memory address
      args.map! do |e|
        if e.start_with? "0x"
          puts "#{ e }: #{ @memory[e.hex_to_dez].bin_to_hex }"
          nil
        else e end
      end
      args.delete nil

      # prints register
      print inspect_register(args[1, args.length - 1])

    end

    ##
    # Returns the content of an Register or an error message if 
    # there is no such register
    #
    def inspect_register regs
      str = ""

      regs.each do |reg|
        found = false
        @register.each do |r|
          if r.name.upcase == reg.upcase
            str += "#{ r.name }: #{ r.to_hex }\n" 
            found = true
            break                   
          end
        end

        str +="unknowen Register #{ reg }\n" unless found
      end

      str
    end

  end
  

end
