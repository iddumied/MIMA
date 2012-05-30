require './lib/MIMA.rb'
require './lib/MIMA/Fixnum.rb'
require 'test/unit'

class ALUTest < Test::Unit::TestCase
  
  include MIMA
  
  def test_add
    alu = ALU.new
    alu.c0 = 1

    x = alu.x
    y = alu.y
    z = alu.z

    100.times do
      x.read = 1
      y.read = 1

      x.bus_read Array.new(24, 0)
      y.bus_read Array.new(24, 0)

      x_val =  Random.rand(2**23)
      y_val =  Random.rand(2**23)
      z_val =  (x_val + y_val).to_bin_ary
      z_val << 0 until z_val.length == 24
 
      x.bus_read x_val.to_bin_ary
      y.bus_read y_val.to_bin_ary

      alu.clk
      z.write = 1

      assert_equal z_val, z.bus_write
    end

  end

end
