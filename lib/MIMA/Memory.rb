require './lib/MIMA/Array.rb'

module MIMA

  ##
  # This class implements the memory of the MIMA.
  # The Memory is controld trough two control signals
  # read an write. 
  # 
  # To read and write you need three clks
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
  class Memory
    
    ##
    # initializes this with a given address length
    # and data length
    #
    def initializes address_len = 20, data_len = 24
      @sar = MIMA::Register.new "SAR", address_len
      @sdr = MIMA::Register.new "SDR", data_len
      @memory = { }
      @clk_state = @read = @write = 0
      @address = @value = nil
    end

    attr_reader :sar, :sdr

    ##
    # Control pipe to set the read status of this
    #
    def read= r
      @read = (r == 1) ? 1 : 0
    end

    ##
    # Control pipe to set the write status of this
    #
    def write= w
      @read = (r == 1) ? 1 : 0
    end

    ##
    # depending on the clk_state if does these things
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
    def clk
      raise RuntimeError.new("Memory can not read and write at the same time") if @write == 1 and @read == 1

      if @read == 1
        clk_read

      elsif @write == 1
        clk_write

      else 
        @clk_state = 0
      end
    end

    private

    ##
    # processes a clk_read, depending on the current clk_state
    # see clk
    #
    def clk_read
      
      case @clk_state

        when 0
          @sar.write = 1
          @sar.read  = 0
          @address = @sar.bus_write.bin_to_dez
          @sar.write = 0

        when 1
          @value = @memory[@address]
          @value = Array.new @sdr.length, 0 if @value.nil?

        when 2
          @sdr.read  = 1
          @sdr.write = 0
          @sdr.bus_read @value
          @sdr.read = 0

      end

      @clk_state += 1
      @clk_state %= 3

    end

    ##
    # processes a clk_write, depending on the current clk_state
    # see clk
    #
    def clk_write
        
      case @clk_state

        when 0
          @sar.write = 1
          @sar.read  = 0
          @address = @sar.bus_write.bin_to_dez
          @sar.write = 0

        when 1
          @sdr.write = 1
          @sdr.read  = 0
          @value = @sdr.bus_write
          @sdr.write = 0

        when 2
          @memory[@address] = @value

      end

      @clk_state += 1
      @clk_state %= 3

    end

  end

end
