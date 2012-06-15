module MIMA
  
  ##
  # A Register is a MIMA bus component.
  # A Register can read and save the current state of
  # the bus pipes and also write its current state to the bus.
  #
  class Register

    ##
    # initialize this with a given name and number of pipes
    # it can read or write (default 24).
    # If the buss containes more pipes it onely read an writes 
    # the last significant pipes.
    #
    def initialize name, num_pipes = 24
      @name = name
      @bits = Array.new(num_pipes, 0)
      @read = @write = 0
    end

    ##
    # Returns the name of this
    #
    def name; @name.clone; end

    ##
    # Read method for bits for user control
    # (not a original mima function)
    #
    def content; @bits.clone; end

    ##
    # A setter method for bits for user control
    # (not a original mima function)
    #
    def content= bits
      if bits.class != Array or (bits.is_a? Array and bits.length != @bits.length)
        raise ArgumentError.new "wrong bits given"
      end

      bits.each_with_index do |e, i|
        @bits[i] = (e == 1) ? 1 : 0
      end
    end

    ##
    # Reads the last significant bits (pipes) from the bus
    # if this should read
    #
    def bus_read pipes
      raise RuntimeError.new("Bus Components can not read and write at the same time") if @write == 1 and @read == 1

      if @read == 1
        length = (pipes.length < @bits.length) ? pipes.length : @bits.length
        0.upto(length-1) { |i| @bits[i] = pipes[i] }
      end
    end

    ##
    # Writes the bits of this to the bus
    # if this should write
    #
    def bus_write
      raise RuntimeError.new("Bus Components can not read and write at the same time") if @write == 1 and @read == 1

      if @write == 1
        @bits.clone
      else
        Array.new(@bits.length, 0)
      end
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
    # Returns the number of Bits this could store
    #
    def length; @bits.length; end

    ##
    # One line description of this
    #
    def inspect
      str = "#<MIMA::Register bits="

      @bits.reverse.each { |b| str += b.to_s }
      str += " read=#{ @read } write=#{ @write } name=#{ @name }>"
    end

    ##
    # Returns a detailed describtion of this
    #
    def describe
      str = "MIMA::Register #{ @name } read(#{ @read }) write(#{ @write })\nBits: "
      @bits.reverse.each { |b| str += b.inspect }
      str += "\n"
    end
    
    ##
    # returns the Hex represenation of this
    #
    def to_hex; @bits.bin_to_hex; end

  end

end
