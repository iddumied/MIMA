require './lib/MIMA/Array.rb'

class Fixnum

  ##
  # converts this into a binary array
  #
  def to_bin_ary length = 0
    x = self
    ary = []

    until x == 0
      ary << x % 2
      x /= 2
    end

    if ary.length < length
      ary << 0 until ary.length == length
    end

    ary
  end

  ##
  # converts this into a hex number
  #
  def to_hex bit_len = 0
    bin = self.to_bin_ary(bit_len)
    bin << 0 until bin.length % 4 == 0
    bin.bin_to_hex
  end

end
