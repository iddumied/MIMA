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
      "HALT" => "0xF0",
      "NOT"  => "0xF1",
      "RAR"  => "0xF2"
    }

    ##
    # The Short Comans (4 Byte) Bits => Ascii equivalent
    #
    SCOMMANDS = {
      [0,0,0,0] => "LDC",
      [1,0,0,0] => "LDV",
      [0,1,0,0] => "STV",
      [1,1,0,0] => "ADD",
      [0,0,1,0] => "AND",
      [1,0,1,0] => "OR",
      [0,1,1,0] => "XOR",
      [1,1,1,0] => "EQL",
      [0,0,0,1] => "JMP",
      [1,0,0,1] => "JMN",
      [0,1,0,1] => "LDIV",
      [1,1,0,1] => "STIV",
      [1,1,1,1] => "LC"   # Long Comand
    }

    ##
    # The Long Commands (8 Byte) Bits => Ascii equivalent
    #
    LCOMMANDS = {
      [0,0,0,0] => "HALT",
      [1,0,0,0] => "NOT",
      [0,1,0,0] => "RAR"

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

    ##
    # Returns the description of this
    #
    def description; @description.clone; end

    ##
    # Returns the bits of this
    #
    def bits; @bits.clone; end

    private

    ##
    # parses an human readable command into its equivalent bits
    #
    def parse
      args = @description.split(" ")

      case args.length
        when 1 then @bits = Array.new(16, 0) + COMMANDS[args.first].hex_to_bin
        when 2 then @bits = args.last.hex_to_bin + COMMANDS[args.first].hex_to_bin
        else raise MimaCodeParseError.new "wrong command length: #{ args.length }"
      end

    end
    

    ##
    # decode an validates the bits array of this
    #
    def decode
      opcode = @bits[@bits.length - 8, 8]

      if SCOMMANDS[opcode[4,4]].nil? or
          (SCOMMANDS[opcode[4,4]] == "LC" and LCOMMANDS[opcode[0,4]].nil?)
        raise ArgumentError.new "OpCode #{ opcode.inspect } unknowen"
      end

      op = (SCOMMANDS[opcode[4,4]] == "LC") ? LCOMMANDS[opcode[0,4]] : SCOMMANDS[opcode[4,4]]
      addr = (SCOMMANDS[opcode[4,4]] == "LC") ? "" : " " + @bits[0, @bits.length - 4].bin_to_hex

      @description = "#{ op }#{ addr }"
    end

  end

end
