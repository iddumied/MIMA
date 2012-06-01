module MIMA

  ##
  # This Class implements an Assembler for the MIMA.
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
  class Assembler
    
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
      "HALT" => "0xF1",
      "NOT"  => "0xF2",
      "RAR"  => "0xF3"
    }

  end

end
