module MIMA

  ##
  # This class implements the ControlUnit of the MIMA.
  # Depending on The OpCode read from the IR (instruction register)
  # generates it controll signal depending on MicroProgramms
  #
  # The OpCodes are:
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
  #  The how the MicroProgramms control the control Pipes can be read at MicroCommand.rb
  #
  class ControlUnit

    ##
    # The Short Comans (4 Byte)
    #
    SCOMANDS = {
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
    # The Long Commands (8 Byte)
    #
    LCOMANDS = {
      [0,0,0,0] => "HALT",
      [1,0,0,0] => "NOT",
      [0,1,0,0] => "RAR"

    }

    ##
    # Returns a MicroCommand for the given String
    #
    def self.micro str
      MIMA::ControlUnit::MicroCommand.new str 
    end

    ##
    # The MicroCommands of this
    # holding the MicroProgramms which
    # implements the MIMA Comands
    #
    # Note ach MicroCommand ins proccessed at one clk
    #
    MICROCOMMANDS = {
    # Addr    Command
      0x00 => micro("IAR -> MAR; IAR -> X; R = 1; ADR 0x01;"),  ##
      0x01 => micro("O -> Y; R = 1; ADR 0x02;"),                # Fetch Phase:
      0x02 => micro("ALU ADD; R = 1; ADR 0x03;"),               # load instrcution add Adress of IRA
      0x03 => micro("Z -> IAR; ADR 0x04;"),                     # and increase IRA
      0x04 => micro("MDR -> IR; ARD 0x05;"),                    # then Decode loaded instruction
      0x05 => micro("D = 1; ADR 0x00;"),                        ##

      0x06 => micro("IR -> Akku; ADR 0x00;")                    # Load Constant into Akku (LDC)

      0x07 => micro("IR -> MAR; R = 1; ADR 0x08;")              ##
      0x08 => micro("R = 1; ADR 0x09;")                         # Load Value (LDV)
      0x09 => micro("R = 1; ADR 0x0A;")                         # loads the value at the address fom IR
      0x0A => micro("MDR -> Akku; ADR 0x00;")                   ##
  
      0x0B => micro("Akku -> MDR; ADR 0x0C;")                   ##
      0x0C => micro("IR -> MAR; W = 1; ADR 0x0D;")              # Store Value (STV)
      0x0D => micro("W = 1; ADR 0x0E")                          # stores the value from Akku at the address from IR
      0x0E => micro("W = 1; ADR 0x00")                          ##

      0x0F => micro("IR -> MAR; R = 1; ADR 0x10;")              ##
      0x10 => micro("Akku -> X; R = 1; ADR 0x11;")              # Akku + value at the Addres from IR (ADD)
      0x11 => micro("R = 1; ADR 0x12;")                         # loads the Akku into X
      0x12 => micro("MDR -> Y; ADR 0x13;")                      # loads the value from the Memory into Y
      0x13 => micro("ALU ADD; ADR 0x14;")                       # Saves the Result in Akku
      0x14 => micro("Z -> Akku; ADR 0x00;")                     ##

      0x15 => micro("IR -> MAR; R = 1; ADR 0x16;")              ##
      0x16 => micro("Akku -> X; R = 1; ADR 0x17;")              # Akku AND value at the Addres from IR (AND)
      0x17 => micro("R = 1; ADR 0x18;")                         # loads the Akku into X
      0x18 => micro("MDR -> Y; ADR 0x19;")                      # loads the value from the Memory into Y
      0x19 => micro("ALU AND; ADR 0x1A;")                       # Saves the Result in Akku
      0x1A => micro("Z -> Akku; ADR 0x00;")                     ##

      0x1B => micro("IR -> MAR; R = 1; ADR 0x1C;")              ##
      0x1C => micro("Akku -> X; R = 1; ADR 0x1D;")              # Akku OR value at the Addres from IR (AND)
      0x1D => micro("R = 1; ADR 0x1E;")                         # loads the Akku into X
      0x1E => micro("MDR -> Y; ADR 0x1F;")                      # loads the value from the Memory into Y
      0x1F => micro("ALU OR; ADR 0x20;")                        # Saves the Result in Akku
      0x20 => micro("Z -> Akku; ADR 0x00;")                     ##

      0x21 => micro("IR -> MAR; R = 1; ADR 0x22;")              ##
      0x22 => micro("Akku -> X; R = 1; ADR 0x23;")              # Akku XOR value at the Addres from IR (XOR)
      0x23 => micro("R = 1; ADR 0x24;")                         # loads the Akku into X
      0x24 => micro("MDR -> Y; ADR 0x25;")                      # loads the value from the Memory into Y
      0x25 => micro("ALU XOR; ADR 0x26;")                       # Saves the Result in Akku
      0x26 => micro("Z -> Akku; ADR 0x00;")                     ##

      0x27 => micro("IR -> MAR; R = 1; ADR 0x28;")              ##
      0x28 => micro("Akku -> X; R = 1; ADR 0x29;")              # Akku EQL value at the Addres from IR (XOR)
      0x29 => micro("R = 1; ADR 0x2A;")                         # loads the Akku into X
      0x2A => micro("MDR -> Y; ADR 0x2B;")                      # loads the value from the Memory into Y
      0x2B => micro("ALU EQL; ADR 0x2C;")                       # Saves the Result in Akku
      0x2C => micro("Z -> Akku; ADR 0x00;")                     ##

      0x2D => micro("IR -> IAR; ADR 0x00;")                     # Jumps to the Addres from IR (JMP, JMN)

      0x2E => micro("IR -> MAR; R = 1; ADR 0x2E;")              ##
      0x2F => micro("R = 1; ADR 0x2F;")                         # Loads the value at the Address stored at the Adress from IR
      0x30 => micro("R = 1; ADR 0x30;")                         # IRA points to Addr, Addr points to value
      0x31 => micro("MDR -> MAR; R = 1; ADR 0x32")              # 
      0x32 => micro("R = 1; ADR 0x33")                          # Indirect Load Value (LDIV)
      0x33 => micro("R = 1; ADR 0x34")                          #
      0x34 => micro("MDR -> Akku; ADR 0x00;")                   ##

      0x35 => micro("IR -> MAR; R = 1; ADR 0x36;")              ##
      0x36 => micro("R = 1; ADR 0x37;")                         # Stores the Akku at the Address stored at the Adress from IR
      0x37 => micro("R = 1; ADR 0x38;")                         # IRA points to Addr, Addr points to were Akku should be stored
      0x38 => micro("MDR -> MAR; ADR 0x39")                     # 
      0x39 => micro("Akku -> MDR; W = 1; ADR 0x3A")             # Indirect Store Value (LDIV)
      0x3A => micro("W = 1; ADR 0x3B")                          #
      0x3B => micro("W = 1; ADR 0x00")                          ##

      0x3C => micro("ADR 0x3C;")                                # endless loop (HALT) stops the MIMA

      0x3D => micro("Akku -> X; ADR 0x3E;")                     ##
      0x3E => micro("ALU NOT; ADR 0x3F")                        # one complement (NOT) of Akku
      0x3F => micro("Z -> Akku; ADR 0x00")                      ##

      0x40 => micro("Akku -> X; ADR 0x41;")                     ##
      0x41 => micro("ALU rotate; ADR 0x42")                     #  Rotate Akku Right (RAR)
      0x42 => micro("Z -> Akku; ADR 0x00")                      ##
    }

    ##
    # Holds the Address of the associated Micro Programm
    #
    MICROPROGRAMMS = {
      # name    address
      "LDC"  => 0x06,
      "LDV"  => 0x07,
      "STV"  => 0x0B,
      "ADD"  => 0x0F,
      "AND"  => 0x15,
      "OR"   => 0x1B,
      "XOR"  => 0x21,
      "EQL"  => 0x27,
      "JMP"  => 0x2D,
      "JMN"  => 0x2D,
      "LDIV" => 0x2E,
      "STIV" => 0x35,
      "HALT" => 0x3C,
      "NOT"  => 0x3D,
      "RAR"  => 0x40,
    }

    ##
    # initialize this with a given length of bus pipes
    # default is 24
    #
    def initialize num_pipes = 24
      @akku   = MIMA::Akku.new num_pipes
      @iar    = MIMA::Register.new "IAR", num_pipes - 4
      @one    = MIMA::Constant.new "One", "0x000001".hex_to_bin
      @ir     = MIMA::IR.new num_pipes
      @alu    = MIMA::ALU.new num_pipes
      @x      = @alu.x
      @y      = @alu.y
      @z      = @alu.z
      @memory = MIMA::Memory.new num_pipes - 4, num_pipes
      @mar    = @memory.mar
      @mdr    = @memory.mdr
      
      # Micro Instruction Pointer
      @mip = 0x00
      @micro = MICROPROGRAMMS[@mip]
    end

    ##
    # Sets the Micro Instruction Pointer to a given Value
    #
    def mip= val
      if val.is_a? Fixnum and MICROCOMMANDS[val].nil?
        raise ArgumentError.new "No MicroCommand at #{ val }"
      elsif val.class != Fixnum
        raise ArgumentError.new "Expected Fixnum, but got #{ val.class }"
      end

      @mip = val
    end

    ##
    # procresses one clk
    #
    def clk
      @micro = MICROCOMMANDS[@mip]
      @mip   = @micro.next_addr
      decode if @micro.decode?
      
      @akku.read    = @micro.akku_reads
      @akku.write   = @micro.akku_writes
      @x.read       = @micro.x_reads
      @y.read       = @micro.y_reads
      @z.write      = @micro.z_writes
      @one.write    = @micro.one_writes
      @iar.read     = @micro.iar_reads
      @iar.write    = @micro.iar_writes
      @ir.read      = @micro.ir_reads
      @ir.write     = @micro.ir_writes
      @mdr.read     = @micro.mdr_reads
      @mrd.write    = @micro.mdr_writes
      @mar.read     = @micro.mar_reads
      @alu.c2       = @micro.alu_c2
      @alu.c1       = @micro.alu_c1
      @alu.c0       = @micro.alu_c0
      @memory.read  = @micro.memory_reads
      @memory.write = @micro.memory_writes
    end

    ##
    # Decodes OpCode from the IR and sets the mip
    # ( Micro Instruction Pointer )
    #
    def decode
      opcode = @ir.opcode
      
      if SCOMANDS[opcode[4,4]].nil? or
          (SCOMANDS[opcode[4,4]] == "LC" and LCOMANDS[opcode[0,4]].nil?
        raise ArgumentError.new "OpCode #{ opcode.inspect } unknowen"
      end

      op = (SCOMANDS[opcode[4,4]] == "LC") ? LCOMANDS[opcode[0,4]] : SCOMANDS[opcode[4,4]]

      if op == "JMN"
        @mip = MICROCOMMANDS[op] if akku.msb == 1
      else
        @mip = MICROPROGRAMMS[op]
      end
    end

  end


end
