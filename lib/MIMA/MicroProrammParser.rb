module MIMA
  
  class ControlUnit

    ##
    # this class implements an parser for the Micro-Programms of the
    # ControlUnit, it parsers Human readable Micro-Programm-Code int
    # Controll signals for the ControlUnit
    # 
    # The Micro-Programm-Code knows the folowing comands:
    #
    # <R1> -> <R2>;     # R1 writes, R2 reads
    # <CP> = <1/0>;     # Sets the Control Pipe CP to 1 / 0
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
    #  22 | One write
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
    #  11 | Memory read
    #  10 | Memory write
    #   9 | reserved
    #   8 | reserved
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
            when "ALU"
            when "ADR"
            else
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
      def set_alu bits, op
        case op
          when "ADD"    then bits[12,3] = [1,0,0]
          when "rotate" then bits[12,3] = [0,1,0] 
          when "AND"    then bits[12,3] = [1,1,0]
          when "OR"     then bits[12,3] = [0,0,1]
          when "XOR"    then bits[12,3] = [1,0,1] 
          when "NOT"    then bits[12,3] = [0,1,1] 
          when "EQL"    then bits[12,3] = [1,1,1] 
          else raise MicroProgrammParser.new("ALU unknowen operation: #{ op }")
        end
      end

    end

  end

end
