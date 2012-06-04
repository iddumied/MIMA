module MIMA

  ##
  # This Class implements an MIMA Command.
  #
  # The Comand Fornat is:
  # 
  #  +----+--------------------+
  #  |Code| Address / Constant |
  #  +----+--------------------+
  #  +----+----+---------------+
  #  | 0xF|Code|  0x0000       |
  #  +----+----+---------------+
  #
  # Knowen Comands are:
  #
  # OpCode | Comand | description
  # -------+--------+--------------------------
  #  0x0   | LDC  c | c -> Akku
  #  0x1   | LDV  a | <a> -> Akku
  #  0x2   | STV  a | Akku -> <a>
  #  0x3   | ADD  a | Akku + <a> -> Akku
  #  0x4   | AND  a | Akku AND <a> -> Akku
  #  0x5   | OR   a | Akku OR <a> -> Akku
  #  0x6   | XOR  a | Akku XOR <a> -> Akku
  #  0x7   | EQL  a | if Akku == <a> -1 -> Akku
  #        |        | else            0 -> Akku
  #  0x8   | JMP  a | a -> IAR
  #  0x9   | JMN  a | if Akku < 0 a -> IAR 
  #  0xA   | LDIV a | <<a>> -> Akku
  #  0xB   | STIV a | Akku -> <<a>>
  #  0xF0  | HATL   | stops the MIMA
  #  0xF1  | NOT    | NOT Akku -> Akku
  #  0xF2  | RAR    | rotate Akku right -> Akku
  #
  class MimaCommand
    
    ##
    # implementaition of an Parse error
    #
    class MimaCodeParseError < RuntimeError
      def initialize str
        super("Error while parsing! " + str)
      end
    end
      
    COMMANDS = {
      "LDC"  => "0x0",
      "LDV"  => "0x1",
      "STV"  => "0x2",
      "ADD"  => "0x3",
      "AND"  => "0x4",
      "OR"   => "0x5",
      "XOR"  => "0x6",
      "EQL"  => "0x7",
      "JMP"  => "0x8",
      "JMN"  => "0x9",
      "LDIV" => "0xA",
      "STIV" => "0xB",
      "HALT" => "0xF1",
      "NOT"  => "0xF2",
      "RAR"  => "0xF3"
    }

    ##
    # initialize this with an given human readable command
    # or an bit array
    #
    def initialize arg
      if arg.is_a? String
        @description = arg
        parse 
      elsif arg.is_a? Array
        @bits = arg
        @description = ""
        decode
      else
        raise ArgumentError.new "expected String or Array, but got #{ arg.class }"
      end
    end

    private

    ##
    # parses an human readable command into its equivalent bits
    #
    def parse
      args = @description.split(" ")

      case args.length
        when 1 then @bits = COMMANDS[args.first].hex_to_bin + args.last.hex_to_bin
        when 2 then @bits = COMMANDS[args.first].hex_to_bin + Array.new(16, 0)
        else raise MimaCodeParseError.new "wrong command length: #{ args.length }"
      end

    end


  end

end
