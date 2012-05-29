##
# This class represents a Bus in The MIMA.
# A Bus has 24 pipes and a set of components attatched to it.
# The Buss reads an writes from each component and then writes its
# status to each component. So its on the components site to 
# Write or Read from the Bus.
#
class Buss

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
        component.methods.include?(:bus_write)
      
      @components << component
    else
      raise ArgumentError.new("not a BussComponent")
    end
  end



end
