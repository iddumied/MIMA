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
    str = "#<MIMA::Bus "
    
    (@pipes.length - 1).downto(0) do |i|
      if @components.empty? && i == 0 then str += "pipe0=#{ @pipes[i] }>"
      else str += "pipe#{ i }=#{ @pipes[i] } " end
    end

    @components.each do |c|
      unless c == @component.last then str += "#{ c } "
      else str += "#{ c }>" end
    end

    str 
  end

  ##
  # Returns a detailed describtion of this
  #
  def describe
    str = "MIMA::Bus\nPipes: "
    @pipes.reverse.each { |p| str += p.inspect }
    str += "\n"
    @components.each { |c| str += c.describe }
    str
  end



end
