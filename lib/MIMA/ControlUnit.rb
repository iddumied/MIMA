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
  #  0x00  | LDC c  | c -> Akku
  #  0x01  | LDV a  | <a> -> Akku
  #  0x02  | STV a  | Akku -> <a>
  #  0x03  | ADD a  | Akku + <a> -> Akku
  #  0x04  | AND a  | Akku AND <a> -> Akku
  #  0x05  | OR  a  | Akku OR <a> -> Akku
  #  0x06  | XOR a  | Akku XOR <a> -> Akku
  #  0x07  | EQL a  | if Akku == <a> -1 -> Akku
  #        |        | else            0 -> Akku
  #  0x08  | JMP a  | a -> IAR
  #  0x09  | JMN a  | if Akku < 0 a -> IAR 
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
      0x05 => micro("D = 1;"),                                  ##

      0x06 => micro("IR -> Akku; ADR 0x00;")                    # Load Constant into Akku (LDC)

      0x07 => micro("IR -> MAR; R = 1; ADR 0x08;")              ##
      0x08 => micro("R = 1; ADR 0x09;")                         # Load Value (LDV)
      0x09 => micro("R = 1; ADR 0x0A;")                         # loads the value at the address fom IR
      0x0A => micro("MDR -> Akku; ADR 0x00;")                   ##
  
      

    }

  end


end
