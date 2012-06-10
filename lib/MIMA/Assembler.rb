module MIMA

  ##
  # This Class implements an Assembler for the MIMA.
  #
  # The MIMA Comand Fornat is:
  # 
  #  +----+--------------------+
  #  |Code| Address / Constant |
  #  +----+--------------------+
  #  +----+----+---------------+
  #  | 0xF|Code|  0x0000       |
  #  +----+----+---------------+
  #
  # Knowen MIMA Comands are:
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
  #  This Assembler has some extra comands and definitions to make programming easyer:
  #
  #  Value Notations:
  #
  #  notation | example | description
  #  ---------+---------+------------
  #   $<var>  | $2A     | hexvalue
  #   0x<var> | 0xFF    | hexvalue
  #   <var>   | 1337    | dezvalue
  #
  #
  #  command            | example         | describtion
  #  -------------------+-----------------+---------------------------------------------
  #   * = <var>         | *      = $10    | Loadpoint: all following comands
  #                     |                 | are saved in the memory starting at <var>
  #   <MARK> = <var>    | ZERO   = 0x0    | defines are Constant
  #   <MARK> DS <var>   | ONE    DS 1     | DS (define storage) reserves mempry space
  #                     | VAR    DS       | and optional sets an initial value
  #   <MARK>: <MIMACMD> | LOOP:  JMP LOOP | defines a jump mark      
  #   <MIMACMD> <MARK>  | LDC    ZERO     | using MIMA commands with marks and constants
  #                     | JMP    END      |
  #                     | STV    VAR      |
  #   <CMD> ; <comment> | ; your comment  | comment cour code                  
  #
  class Assembler
    
    COMMANDS  = MIMA::MimaCommand::COMMANDS
    SCOMMANDS = MIMA::MimaCommand::SCOMMANDS
    LCOMMANDS = MIMA::MimaCommand::LCOMMANDS

    ##
    # implementation of an assembler parse error
    #
    class AssemberParseError < RuntimeError
      def initilaize str
        if str.is_a? Array
          str = str.inspect.gsub("[", "").gsub("]", "").gsub(",", "")
        end

        super "Error while parsing MIMA Assembler: #{ str }"
      end
    end

    ##
    # initialize this with an given File
    # or String including an Mima assembler file
    #
    def initialize arg
      if arg.is_a? File
        @source = arg.read
      elsif arg.is_a? String
        @source = arg
      else
        raise ArgumentError.new "expected File or String, but got #{ arg.class }"
      end

      @marks = { }
      @memory = { }
    end

    ##
    # removes the comments form @source, 
    # split each line by tabs and spaces 
    # and saves the result it in @code
    # as an two dimensional array of lines and words
    #
    def parse_source
      @code = []

      @source.each_line do |line|
        new_line = ""

        # remove comments
        line.each_char do |char|
          break if char == ";"
          new_line << char
        end

        new_line = new_line.split(" ").map { |e| e.split("\t") }.flatten
        next if new_line.empty?
        
        @code << new_line
      end

      @code
    end

    ##
    # Parses the assembler code in @code
    # and Saves the result in @memory
    # in the formt: addr => MimaCommand
    #
    def parse_code
      addr = 0x0

      @code.each_with_index do |line, i|

        # an mima assembler command is consist of 2 or 3 words
        unless [2, 3].include? line.length
          raise AssemberParseError.new line
        end

        case line.file
          when "*" : addr = parse_var(str.last)


        end        

      end

    end

    ##
    # parsing an loadpoint and returns the defined value
    #
    def parse_loadpoint args
      if args[1] != "=" or args.length != 3
        raise AssemberParseError.new args
      end
    end

    ##
    # parses an value and returns the decimal represenation of it
    # values can bee:
    #
    #  notation | example | description
    #  ---------+---------+------------
    #   $<var>  | $2A     | hexvalue
    #   0x<var> | 0xFF    | hexvalue
    #   <var>   | 1337    | dezvalue
    #
    def parse_var str
      if str.start_with? "$"
        str.gsub("$", "0x").hex_to_dez
      elsif str.start_with? "0x"
        str.hex_to_dez
      else
        str.to_i
      end
    end
    
  end

end
