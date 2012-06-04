module MIMA

  ##
  # This class implements the MIMA it self
  # for the layout of the Mima see README
  #
  class Mima
    
    ##
    # initialize this with a given number of pipes
    # default 24
    #
    def initialize num_pipes = 24
      @controlunit = MIMA::ControlUnit.new num_pipes

      
    end

  end
  

end
