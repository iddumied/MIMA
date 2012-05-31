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
    # <CP> = 1;     # Sets the Control Pipe CP to 1 / 0 (CP can be R, W, D)
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
    class MicroProgrammParser

      ##
      # implementaition of an Parse error
      #
      class MicroCodeParseError < RuntimeError
        def initialize str
          super("Error while parsing! " + str)
        end
      end
      
      ##
      # parses a given Micro-Programm-Code and returns the bit Array for the ControlUnit
      #
      def self.parse str
        bits = Array.new 28, 0

        str.split(";").each do |comand|
          args = comand.split(" ")

          case args.first
            when "ALU" then set_alu(bits, args[1])
            when "ADR" then set_addr(bits, args[1])
            else            set_register_op(bits, args)
          end
        end
      end

      ##
      # sets the ALU control bits in the given bits Array 
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
      def self.set_alu bits, op
        case op
          when "ADD"    then bits[12,3] = [1,0,0]
          when "rotate" then bits[12,3] = [0,1,0] 
          when "AND"    then bits[12,3] = [1,1,0]
          when "OR"     then bits[12,3] = [0,0,1]
          when "XOR"    then bits[12,3] = [1,0,1] 
          when "NOT"    then bits[12,3] = [0,1,1] 
          when "EQL"    then bits[12,3] = [1,1,1] 
          else raise MicroCodeParseError.new("ALU unknowen operation: #{ op }")
        end
      end

      ##
      # Sets the given addr in the given bits Array
      #
      def self.set_addr bits, addr
        addr = addr.split("x").last
        unless addr.length == 2
          raise MicroCodeParseError.new("wrong address length")
        end

        for i in (0..1) do
          case addr[i].upcase
            when "0" then bits[(i-1).abs * 4, 4] = [0,0,0,0]
            when "1" then bits[(i-1).abs * 4, 4] = [1,0,0,0]
            when "2" then bits[(i-1).abs * 4, 4] = [0,1,0,0]
            when "3" then bits[(i-1).abs * 4, 4] = [1,1,0,0]
            when "4" then bits[(i-1).abs * 4, 4] = [0,0,1,0]
            when "5" then bits[(i-1).abs * 4, 4] = [1,0,1,0]
            when "6" then bits[(i-1).abs * 4, 4] = [0,1,1,0]
            when "7" then bits[(i-1).abs * 4, 4] = [1,1,1,0]
            when "8" then bits[(i-1).abs * 4, 4] = [0,0,0,1]
            when "9" then bits[(i-1).abs * 4, 4] = [1,0,0,1]
            when "A" then bits[(i-1).abs * 4, 4] = [0,1,0,1]
            when "B" then bits[(i-1).abs * 4, 4] = [1,1,0,1]
            when "C" then bits[(i-1).abs * 4, 4] = [0,0,1,1]
            when "D" then bits[(i-1).abs * 4, 4] = [1,0,1,1]
            when "E" then bits[(i-1).abs * 4, 4] = [0,1,1,1]
            when "F" then bits[(i-1).abs * 4, 4] = [1,1,1,1]
            else raise MicroCodeParseError.new("Not a hex number: #{ addr[i] }")
          end
        end

      end

      ##
      # sets the Flags in a given bit array depending on the given operation
      #
      def set_register_op bits, op
        unless op.length == 3
          raise MicroCodeParseError.new("not an Micro Code Operation")
        end

        case op[1]
          when "->" then write_read(bits, op) 
          when "="  then zuweisung(bits, op)
          else raise MicroCodeParseError.new("Unknowen Register operation: #{ op[1] }")
        end
      end

      ##
      # sets the bits of an 
      # <R1> -> <R2> operation
      #
      # where R1, can be: Akku, Z, O, IAR, IR, MDR
      # and R2 can be: Akku, IAR, IR, X, Y, MAR, MDR
      #
      def write_read bits, op

        # Register writes
        case op.first
          when "Akku" then bits[26] = 1
          when "Z"    then bits[23] = 1
          when "O"    then bits[22] = 1
          when "IAR"  then bits[20] = 1
          when "IR"   then bits[18] = 1
          when "MDR"  then bits[16] = 1
          else
        end

        # Register reads
        case op.last
          when "Akku" then bits[27] = 1
          when "IAR"  then bits[21] = 1
          when "IR"   then bits[19] = 1
          when "X"    then bits[25] = 1
          when "Y"    then bits[24] = 1
          when "MAR"  then bits[15] = 1
          when "MDR"  then bits[17] = 1
          else
        end

      end

      ##
      # Sets the Bits of an 
      # <CP> = 1 operation
      #
      # where CP can be: R, W, D
      #
      def zuweisung bits, op #TODO zuweisung -> englisch
        unless op.last == "1"
          raise MicroCodeParseError.new("invalid operand #{ op.last }")
        end

        case op.first
          when "R" then bits[11] = 1
          when "W" then bits[10] = 1
          when "D" then bits[8,2] = [1, 1] 
          else raise MicroCodeParseError.new("Unknowen Register: #{ op.first }")
        end

      end

    end

  end

end
