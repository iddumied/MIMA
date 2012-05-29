module MIMA

  ##
  # This class implements the memory of the MIMA.
  # The Memory is controld trough two control signals
  # read an write. 
  # 
  # To read and write you ned three clks
  #  
  # if read is on:
  #   1. load the Addres from the SAR Speicher-Address-Register 
  #      ( Memory-Addres-Register )
  #   2. load the value at the loaded address
  #   3. store the loaded Value into SDR Speicher-Daten-Register
  #      ( Memory-Data-Register )
  #
  # if write is on
  #   1. load the Address from SAR
  #   2. load the value from SDR
  #   3. store the value on the previous loaded addres from SAR
  #
  # so it takes three clk to read and write to the Memory
  #
  class Memory
    
    ##
    # initializes this with a given address length
    # and data length
    #
    def initializes address_len = 20, data_len = 24
      @sar = MIMA::Register.new "SAR", address_len
      @sdr = MIMA::Register.new "SDR", data_len
      @memory = { }
    end

  end

end
