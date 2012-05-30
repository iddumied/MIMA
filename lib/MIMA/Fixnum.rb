class Fixnum

  ##
  # converts this into an binary array
  #
  def to_bin_ary
    x = self
    ary = []

    until x == 0
      ary << x % 2
      x /= 2
    end

    ary
  end

end
