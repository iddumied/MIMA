require './lib/MIMA.rb'
require 'test/unit'

##
# This is a complex test of the Mima.
#
# It sortes an array beginning at address 0x00000.
# The Last address of the array (the array length -1) is at address 0x00040.
# The Programmcode will be at 0x00100.
# The addresses from 0x0080 to 0x000FF are used for temporary values
# When finished the sorted array beginns at 0x00000 in ascending order
# 
# Here is a Pseudo Assembler implementaition of the code of this test:
#
# ; Value definitions
# * = 0x00080                ; loadpoint
# VAR1      DS               ; define storage for
# VAR2      DS               ; programm values
# VAR1ADDR  DS               ; (DS = Define Storage)
# VAR2ADDR  DS               ;
# TEMP      DS               ;
# INDEX     DS               ;
# NOTSORTED DS               ;
#                 
# * = 0x00100     
# START:    LDC   0x00000    ; load start addres of the array
#           STV   INDEX      ; and save it in INDEX
#           STV   NOTSORTED  ; sets NOTSORTED = 0
# NEXT:     LDV   INDEX      ; 
#           EQL   0x00040    ; 
#           JMN   ISENDE     ; jump if end of array is reached
#           LDV   INDEX      ;
#           STV   VAR1ADDR   ; 
#           LDC   0x00001    ; 
#           ADD   INDEX      ; increases INDEX
#           STV   INDEX      ; and stores it
#           STV   VAR2ADDR   ; 
#           LDIV  VAR2ADDR   ; 
#           STV   VAR2       ; loads ans stores:
#           LDIV  VAR1ADDR   ; VAR1 = array[INDEX] 
#           STV   VAR1       ; VAR2 = array[INDEX + 1]
#           NOT              ; 
#           ADD   VAR2       ; compares VAR1 and VAR2
#           NOT              ; ( ~(~VAR1 + VAR2) < 0  => VAR1 < VAR2 
#           JMN   NEXT       ;  
#           LDV   VAR1       ; switch VAR1, VAR2
#           STV   TEMP       ;
#           LDV   VAR2       ;
#           STIV  VAR1ADDR   ;
#           LDV   TEMP       ;
#           STIV  VAR2ADDR   ;
#           LDC   0x00001    ;
#           STV   NOTSORTED  ; sets NOTSORTED = 1
#           JMP   NEXT       ;
# ISENDE:   LDC   0x00001    ;
#           EQL   NOTSORTED  ; jump to start if array not sorted yet
#           JMN   START      ;
#           HALT             ; programm finisehd
#
class MimaBubblesortTest < Test::Unit::TestCase
  
  include MIMA

  ##
  # Returns a new MimaCommand for str (as binary array)
  #
  def cmd str; MimaCommand.new(str).bits; end
  
  def test_bubblesort
    mima = Mima.new
    memory = mima.memory

    # add random sorted array to memory
    0x0.upto(0x10) { |i| memory[i] = Random.rand(2**23).to_bin_ary(24) }

    # letting 0x00040 pointing to the last array index
    memory[0x40] = "0x000010".hex_to_bin

    # the Mima BubbleSort programm
    #
    # the pseudo Assembler values will be repleaced with
    #
    # VAR1      0x00080
    # VAR2      0x00081
    # VAR1ADDR  0x00082
    # VAR2ADDR  0x00083
    # TEMP      0x00084
    # INDEX     0x00085
    # NOTSORTED 0x00086
    #
    programm = {
      0x100 => cmd("LDC   0x00000"),
      0x101 => cmd("STV   0x00085"),      
      0x102 => cmd("STV   0x00086"), 
      0x103 => cmd("LDV   0x00085"), 
      0x104 => cmd("EQL   0x00040"),    
      0x105 => cmd("JMN   0x0011D"),   
      0x106 => cmd("LDV   0x00085"),    
      0x107 => cmd("STV   0x00082"),
      0x108 => cmd("LDC   0x00001"),
      0x109 => cmd("ADD   0x00085"), 
      0x10A => cmd("STV   0x00085"),
      0x10B => cmd("STV   0x00083"),  
      0x10C => cmd("LDIV  0x00083"), 
      0x10D => cmd("STV   0x00081"),    
      0x10E => cmd("LDIV  0x00082"), 
      0x10F => cmd("STV   0x00080"),    
      0x110 => cmd("NOT"),    
      0x111 => cmd("ADD   0x00081"),    
      0x112 => cmd("NOT"),    
      0x113 => cmd("JMN   0x00103"),    
      0x114 => cmd("LDV   0x00080"),
      0x115 => cmd("STV   0x00084"),       
      0x116 => cmd("LDV   0x00081"),      
      0x117 => cmd("STIV  0x00082"), 
      0x118 => cmd("LDV   0x00084"),    
      0x119 => cmd("STIV  0x00083"),  
      0x11A => cmd("LDC   0x00001"),  
      0x11B => cmd("STV   0x00086"), 
      0x11C => cmd("JMP   0x00103"),     
      0x11D => cmd("LDC   0x00001"),  
      0x11E => cmd("EQL   0x00086"),
      0x11F => cmd("JMN   0x00100"),
      0x120 => cmd("HALT         "),
    }          
              
    # load prog into memory
    programm.each { |k,v| memory[k] = v }

    # setting prog start address
    mima.iar.content = "0x00100".hex_to_bin

    f = File.open("bublesort.log", "w");
    Thread.new do
      loop do
        0x0.upto(0x10) { |i| f.print "#{ memory[i].bin_to_hex } " }
        f.puts "\n"
        f.close

        f = File.open("bublesort.log", "a");
        sleep 1
      end
    end
    # run programm
    mima.run_until_halt 

    # print array
    0x0.upto(0x10) { |i| puts "#{ i.to_bin_ary(24).bin_to_hex }: #{ memory[i].bin_to_hex }" }

  end

end
