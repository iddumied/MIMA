module MIMA

  ##
  # This class implements the memory of the MIMA.
  # The Memory is controld trough two control signals
  # read an write. 
  # 
  # To read and write you need three clks
  #  
  # if read is on:
  #   1. load the Addres from the MAR ( Memory-Addres-Register )
  #   2. load the value at the loaded address
  #   3. store the loaded Value into MDR  ( Memory-Data-Register )
  #
  # if write is on
  #   1. load the Address from MAR
  #   2. load the value from MDR
  #   3. store the value on the previous loaded addres from MAR
  #
  class Memory
    
    ##
    # initializes this with a given address length
    # and data length
    #
    def initialize address_len = 20, data_len = 24
      @mar = MIMA::Register.new "MAR", address_len
      @mdr = MIMA::Register.new "MDR", data_len
      @memory = { }
      @clk_state = @read = @write = 0
      @address = @value = nil
    end

    attr_reader :mar, :mdr

    ##
    # accress a valu in the memory directly by the user
    # (not a real MIMA function)
    #
    def [] index
      if index.class != Fixnum or index >= 2**(@mar.length) or index < 0
        raise ArgumentError.new "wrong address #{ index.inspect }"
      end

      return Array.new(@mdr.length, 0) if @memory[index].nil?
      @memory[index]
    end

    ##
    # insert a value into the memory, used to control
    # the MIMA state direcly by the user (not a real MIMA function)
    #
    def []= index, value
      if index.class =! Fixnum or value.class != Array or
          index >= 2**(@mar.length) or index < 0 or value.length != @mdr.length

        raise ArgumentError.new "wrong index and / or value given"
      end

      @memory[index] = value
    end

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
      @write = (w == 1) ? 1 : 0
    end

    ##
    # depending on the clk_state if does these things
    # 
    # if read is on:
    #   1. load the Addres from the MAR ( Memory-Addres-Register )
    #   2. load the value at the loaded address
    #   3. store the loaded Value into MDR  ( Memory-Data-Register )
    #
    # if write is on
    #   1. load the Address from MAR
    #   2. load the value from MDR
    #   3. store the value on the previous loaded addres from MAR
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
          @mar.write = 1
          @mar.read  = 0
          @address = @mar.bus_write.bin_to_dez
          @mar.write = 0

        when 1
          @value = @memory[@address]
          @value = Array.new @mdr.length, 0 if @value.nil?

        when 2
          @mdr.read  = 1
          @mdr.write = 0
          @mdr.bus_read @value
          @mdr.read = 0

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
          @mar.write = 1
          @mar.read  = 0
          @address = @mar.bus_write.bin_to_dez
          @mar.write = 0

        when 1
          @mdr.write = 1
          @mdr.read  = 0
          @value = @mdr.bus_write
          @mdr.write = 0

        when 2
          @memory[@address] = @value

      end

      @clk_state += 1
      @clk_state %= 3

    end

  end

end
