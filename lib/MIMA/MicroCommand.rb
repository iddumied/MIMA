require './lib/MIMA/String.rb'

module MIMA
  
  class ControlUnit

    ##
    # this class implements an parser for the Micro-Programms of the
    # ControlUnit, it parsers Human readable Micro-Programm-Code int
    # Controll signals for the ControlUnit
    # 
    # The Micro-Programm-Code knows the folowing comands:
    #
    # <R1> -> <R2>;     # R1 writes, R2 reads (R1 can be Z, O, Akku, IRA, IR, MDR; 
    #                   #   R2 can be X, Y, Akku, IRA, IR,  MAR, MDR)
    # <CP> = 1;         # Sets the Control Pipe CP to 1 / 0 (CP can be R, W, D)
    # ALU ADD;          # lets the ALU calculate X + Y -> Z
    # ALU rotate;       # lets the ALU calculate rotate x right -> Z
    # ALU AND;          # lets the ALU calculate X AND Y -> Z
    # ALU OR;           # lets the ALU calculate X OR Y -> Z
    # ALU XOR;          # lets the ALU calculate X XOR Y -> Z
    # ALU NOT;          # lets the ALU calculate NOT X -> Z
    # ALU EQL;          # lets the ALU calculate if X == Y, -1 -> Z else 0 -> Z
    # ADR 0x<Address>;  # Sets the address of the folloing Micro-Programm-Comand
    #
    # The Following bits in a Microprogramm Code can be setted trought the discussed Comands:
    #
    # Bit | Control Pipe
    # ------------------
    #  27 | Akku read
    #  26 | Akku write
    #  25 | X read
    #  24 | Y read
    #  23 | Z write
    #  22 | O (One) write
    #  21 | IAR read
    #  20 | IAR write
    #  19 | IR read
    #  18 | IR write
    #  17 | MDR read
    #  16 | MDR write
    #  15 | MAR read
    #  14 | ALU C2
    #  13 | ALU C1
    #  12 | ALU C0
    #  11 | R (Memory read)
    #  10 | W (Memory write)
    #   9 | D (Decode OpCode)
    #   8 | D (Decode OpCode)
    #   7 | next Address
    #   6 | next Address
    #   5 | next Address
    #   4 | next Address
    #   3 | next Address
    #   2 | next Address
    #   1 | next Address
    #   0 | next Address
    #
    # Note each Micro-Programm-Code-Line must end with the addres of the next Micro-Programm-Comand
    # and each Micro-Programm-Comand must end with an Semicolon
    #
    class MicroCommand

      ##
      # implementaition of an Parse error
      #
      class MicroCodeParseError < RuntimeError
        def initialize str
          super("Error while parsing! " + str)
        end
      end
      
      ##
      # The position of the read Flags of the Register 
      # which could read from the bus
      #
      @@read = {
        "Akku" => 27,
        "X"    => 25,
        "Y"    => 24,
        "IRA"  => 21,
        "IR"   => 19,
        "MDR"  => 17,
        "MAR"  => 15
      }

      ##
      # The position of the write Flags of the Register 
      # which could write to the bus
      #
      @@write = {
        "Akku" => 26,
        "Z"    => 23,
        "O"    => 22,
        "IRA"  => 20,
        "IR"   => 18,
        "MDR"  => 16
      }

      ##
      # The C0, C1, C2
      # Flag for the specifig ALU operation
      # the Flags are at the position C0(12), C1(13), C2(14)
      #
      @@alu_falgs = {
        "ADD"    => [1,0,0],
        "rotate" => [0,1,0], 
        "AND"    => [1,1,0],
        "OR"     => [0,0,1],
        "XOR"    => [1,0,1],
        "NOT"    => [0,1,1],
        "EQL"    => [1,1,1] 
      }

      ##
      # Flags:
      #
      # R, W for the Memory
      # D (Decode) for the ControlUnit
      #
      @@flags = {
        "R" => 11,
        "W" => 10,
        "D" => 9
      }

      ##
      # initialize this with a given String or MicroProgramm Array
      #
      def initialize arg
        if arg.is_a? String
          @bits = Array.new 28, 0
          @description = arg
          parse 
        elsif a.is_a? Array
          @bits = arg
          @description = ""
          decode
        else
          raise ArgumentError.new "expected String or Array, but got #{ arg.class }"
        end
      end

      ##
      # parses a Micro-Programm-Code description and sets the falgs in the bits Array
      #
      def parse 
        @description.split(";").each do |comand|
          args = comand.split(" ")

          case args.first
            when "ALU" then set_alu(args[1])
            when "ADR" then set_addr(args[1])
            else            set_register_op(args)
          end
        end
      end

      ##
      # sets the ALU control flags in the bits Array 
      # depending on the given ALU operation:
      # 
      # Operation    | C2 C1 C0
      # -----------------------
      # ALU ADD;     |  0  0  1 
      # ALU rotate;  |  0  1  0
      # ALU AND;     |  0  1  1
      # ALU OR;      |  1  0  0
      # ALU XOR;     |  1  0  1
      # ALU NOT;     |  1  1  0
      # ALU EQL;     |  1  1  1
      #
      def set_alu op
        if @@alu_falgs[op].nil?
          raise MicroCodeParseError.new("ALU unknowen operation: #{ op }")
        end

        @bits[12,3] = @@alu_falgs[op]
      end

      ##
      # Sets the given addr in the given bits Array
      # addr should be something like 0x??
      #
      def set_addr addr
        unless addr.length == 4
          raise MicroCodeParseError.new("wrong address length")
        end

        @bits[0, 8] = addr.hex_to_bin
      end

      ##
      # sets the Flags in a given bit array depending on the given operation
      #
      def set_register_op op
        unless op.length == 3
          raise MicroCodeParseError.new("not an Micro Code Operation")
        end

        case op[1]
          when "->" then reg_copy(op) 
          when "="  then allocation(op)
          else raise MicroCodeParseError.new("Unknowen Register operation: #{ op[1] }")
        end
      end

      ##
      # sets the bits of an 
      # <R1> -> <R2> operation (R1 copy into R2)
      #
      # where R1, can be: Akku, Z, O, IAR, IR, MDR
      # and R2 can be: Akku, IAR, IR, X, Y, MAR, MDR
      #
      def reg_copy op
        if @@write[op.first].nil?
          raise MicroCodeParseError.new("Register #{ op } unknowen / can not read")
        elsif @@read[op.last].nil?
          raise MicroCodeParseError.new("Register #{ op } unknowen / can not read")
        end

        @bits[@@write[op.first]] = 1
        @bits[@@read[op.last]] = 1
      end

      ##
      # Sets the Bits of an 
      # <CP> = 1 operation
      #
      # where CP can be: R, W, D
      #
      def allocation op #TODO zuweisung -> englisch
        if @flags[op.first].nil?
          raise MicroCodeParseError.new("Unknowen Register: #{ op.first }")
        elsif op.last != "1"
          raise MicroCodeParseError.new("invalid operand #{ op.last }")
        end

        @bits[@@flags[op.first]] = 1
      end

      ##
      # decode an validates the bits array of this
      # validates means that it detects collisons 
      # if two register write.
      #
      def decode
 
        nil
        
 
      end

    end
    
  end

end
