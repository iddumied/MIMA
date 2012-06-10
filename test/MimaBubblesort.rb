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
#           STV   TEMP       ; TEMP = VAR1
# COMPAR:   JMN   BIGGER     ; if TEMP < 0 
#           EQL   VAR2       ; if TEMP == VAR2
#           JMN   SMALER     ; 
#           LDC   0x00001    ;  inc TEMP untill its equal to VAR2 => VAR1 <= VAR2
#           ADD   TEMP       ;  or untill TEMP is smaler zero     => VAR1 >  VAR2
#           STV   TEMP       ;
#           JMP   COMPAR     ;
# SMALER:   JMP   NEXT       ; process next array indexes
# BIGGER:   LDV   VAR1       ; switch VAR1, VAR2
#           STV   TEMP       ;
#           LDV   VAR2       ;
#           STV   VAR1ADDR   ;
#           LDV   TEMP       ;
#           STV   VAR2ADDR   ;
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
  
  def test_bubblesort

  end

end
