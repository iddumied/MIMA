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
  #   <MARK> = <var>    | ZERO   = 0x0    | defines a Constant
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
    # you can also set a number of pipes of the mima
    # ( with is also be the bit length of an value in the memory )
    # default is 24
    #
    def initialize arg, num_pipes = 24
      if arg.is_a? File
        @source = arg.read
      elsif arg.is_a? String
        @source = arg
      else
        raise ArgumentError.new "expected File or String, but got #{ arg.class }"
      end

      @marks = { }
      @memory = { }
      @num_pipes = num_pipes
    end

    attr_reader :marks, :source, :memory, :code

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
      @addr = 0x0

      @code.each_with_index do |line, i|
        @parse_index = i

        # an mima assembler command is consist of 2 or 3 words
        unless [1, 2, 3].include? line.length
          raise AssemberParseError.new line
        end

        if line.length == 1
          define_jum_mark line

        elsif line.first == "*" 
          @addr = parse_loadpoint(line)

        elsif COMMANDS.include? line.first 
          @memory[@addr] = parse_mima_cmd(line)
          @addr += 1

        else
          parse_marke line

        end        

      end

      # clean up
      @addr = nil
      @parse_index = nil
    end

    ##
    # parsing an loadpoint and returns the defined value
    #
    def parse_loadpoint args
      if args[1] != "=" or args.length != 3
        raise AssemberParseError.new args
      end

      parse_var args.last
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
    
    ##
    # parses an mima comand
    # in the form <MIMACOMAND> <MARK/VALUE>
    #
    # see Assember class describtion for 
    # list of avilabel comands
    #
    def parse_mima_cmd args
      unless args.length == 2
        raise AssemberParseError.new args
      end

      # if a value is given
      if /[0-9$]/.match args.last[0]
        var = parse_var(str).to_hex(@num_pipes)
        MIMA::MimaCommand.new "#{ args.first } #{ var }"

      # mark is given
      else 
        if @marks.include? args.last
          MIMA::MimaCommand.new "#{ args.first } #{ @marks[args.last] }"

        else
          var = find_mark
          MIMA::MimaCommand.new "#{ args.first } #{ var }"
       
        end

      end

    end

    ##
    # finds a jump mark after current parse position
    #
    def find_mark mark
      addr = @addr

      for i in (@parse_index...(@code.length)) do

        # if mark found save to marks and return addr
        if @code[i].first == mark
          @marks[mark] = addr.to_hex(@num_pipes)
          return @marks[mark]
        
        # if loadpoint found actualize addr
        elsif @code[i].first == "*"
          addr = parse_loadpoint(@code[i])
          
        # skip jump marks and constant definitions
        elsif @code[i].length != 1 and @code[i][1] != "="
          addr += 1

        end

      end

      raise AssemberParseError.new "Jump-Mark #{ mark } not found"
    end

    ##
    # parses a mark definition:
    #
    #  command            | example         | describtion
    #  -------------------+-----------------+---------------------------------------------
    #   <MARK> = <var>    | ZERO   = 0x0    | defines are Constant
    #   <MARK> DS <var>   | ONE    DS 1     | DS (define storage) reserves mempry space
    #                     | VAR    DS       | and optional sets an initial value
    #   <MARK>: <MIMACMD> | LOOP:  JMP LOOP | defines a jump mark      
    #
    # increases @addr if nedded 
    # and adds a mima command to the memory if nedded
    #
    def parse_marke args
      if args[1] == "="
        create_constant args

      elsif args[1] == "DS"
        define_storage args
        @addr += 1

      elsif COMMANDS.include? args[1] 
        define_jum_mark args
        @addr += 1

      else
        raise AssemberParseError.new args
      end
    end

    ##
    # creates a constant and seaves it to the marks Hash
    #
    def create_constant args
      @marks[args.first] = parse_var(args.last).to_hex(@num_pipes)
    end

    ##
    # defines a storage, saves it to the marks Hash
    # and into the memory at @addr
    #
    def define_storage args
      @marks[args.first] = @addr.to_hex(@num_pipes)

      if args.length == 3
        @memory[@addr] = parse_var(args.last)
      end
    end
    
    ##
    # defines a jump mark and saves it to the marks Hash
    # also saves a ruby comand to @memory if nedded
    #
    def define_jum_mark args
      if /[A-Za-z]/.match(args.first[0]).nil? or
                args.first.end_with?(":") == false
        raise AssemberParseError.new "Not a valid Jump-Marke: #{ args.first }"
      end

      if args.length == 1
        @marks[args.first.chop] = @addr.to_hex(@num_pipes)

      elsif 
        @marks[args.first.chop] = @addr.to_hex(@num_pipes)
        @memory[@addr] = parse_mima_cmd(args[1,2])

      end

    end

  end

end
