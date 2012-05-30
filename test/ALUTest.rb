require './lib/MIMA.rb'
require './lib/MIMA/Fixnum.rb'
require 'test/unit'

class ALUTest < Test::Unit::TestCase
  
  include MIMA
  
  def test_do_nothing
    alu = ALU.new

    x = alu.x
    y = alu.y
    z = alu.z

    1000.times do
      x.read = 1
      y.read = 1
      z.read = 1
      x.write = 0
      y.write = 0
      z.write = 0

      x.bus_read Array.new(24, 0)
      y.bus_read Array.new(24, 0)
      z.bus_read Array.new(24, 0)

      x_val =  Random.rand(2**24).to_bin_ary
      y_val =  Random.rand(2**24).to_bin_ary
      z_val =  Random.rand(2**24).to_bin_ary
      x_val << 0 until x_val.length == 24
      y_val << 0 until y_val.length == 24
      z_val << 0 until z_val.length == 24

 
      x.bus_read x_val
      y.bus_read y_val
      z.bus_read z_val

      alu.clk
      x.read = 0
      y.read = 0
      z.read = 0
      z.write = 1
      x.write = 1
      y.write = 1

      assert_equal x_val, x.bus_write
      assert_equal y_val, y.bus_write
      assert_equal z_val, z.bus_write
    end

  end

  def test_add
    alu = ALU.new
    alu.c0 = 1

    x = alu.x
    y = alu.y
    z = alu.z

    1000.times do
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
