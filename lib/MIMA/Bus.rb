module MIMA

  ##
  # This class represents a Bus in The MIMA.
  # A Bus has 24 pipes and a set of components attatched to it.
  # The Buss reads an writes from each component and then writes its
  # status to each component. So its on the components site to 
  # Write or Read from the Bus.
  #
  class Bus

    ##
    # initialize this Bus with an empty components set
    # and a given number of pipes (default 24)
    #
    def initialize num_pipes = 24
      @components = []
      @pipes = Array.new(num_pipes, 0)
    end
    
    ##
    # Validate and Adds a new coponent to this
    # A component should implement an bus_write method
    # which returns an array of pipe states (0 or 1)
    # and an bus_read method with takes an array of 
    # pipe sates.
    #
    def add component
      if component.methods.include?(:bus_read) and
          component.methods.include?(:bus_write) and
            component.methods.include?(:describe) and
              component.methods.include?(:inspect)
        
        @components << component
      else
        raise ArgumentError.new("not a BussComponent")
      end
    end

    ##
    # One line description of this
    #
    def inspect
      str = "#<MIMA::Bus pipes="

      @pipes.reverse.each { |p| str += p.to_s }
      if @components.empty?
        str += " components=[]>" 
      else
        str += " components=["
      end

      @components.each do |c|
        unless c == @components.last then str += "#{ c }, "
        else str += "#{ c.inspect }]>" end
      end

      str 
    end

    ##
    # Returns a detailed describtion of this
    #
    def describe
      str = "MIMA::Bus\nPipes: "
      @pipes.reverse.each { |p| str += p.inspect }
      str += "\nComponents:\n"
      @components.each { |c| str += c.describe }
      str
    end

    ##
    # Simulates one clock signal.
    # First this Bus reads from each component (the component writes to the bus)
    # then this Bus writes to each component (the component reads from the bus)
    # so ist on the component site to eccept the read or write
    #
    def clk
      write = nil
      
      # clear all pipes
      @pipes.map!{ 0 }

      # read from components
      @components.each do |c|
        c.bus_write.each_with_index do |pipe, i|
          if pipe == 1
            if write != nil and write != c.name
              raise RuntimeError.new "Collection detected! #{ write } and #{ c.name } writing"
            end

            @pipes[i] = 1 
            write = c.name
          end
        end
      end

      puts "[DEBUG] #{ @pipes.bin_to_dez }"

      # write to components
      @components.each { |c| c.bus_read @pipes.clone }

      @pipes.clone
    end

  end

end
