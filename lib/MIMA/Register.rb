module MIMA
  
  ##
  # A Register is a MIMA bus component.
  # A Register can read and save the current state of
  # the bus pipes and also write its current state to the bus.
  #
  class Register

    ##
    # initialize this with a given number of pipes
    # it can read or write (default 24).
    # If the buss containes more pipes it onely read an writes 
    # the last significant pipes.
    #
    def initialize num_pipes = 24
      @bits = Array.new(num_pipes, 0)
      @read = @write = 0
    end

    ##
    # Reads the last significant bits (pipes) from the bus
    # if this should read
    #
    def bus_read pipes
      if @read == 1
        for i in (0...@bits.length) do
          @bits[i] = pipes[i]
        end
      end
    end

    ##
    # Writes the bits of this to the bus
    # if this should write
    #
    def bus_write
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
      @read = (r == 1) ? 1 : 0
    end

  end

end
