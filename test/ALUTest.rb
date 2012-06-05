require './lib/MIMA.rb'
require 'test/unit'

class ALUTest < Test::Unit::TestCase
  
  include MIMA
  
  def test_do_nothing
    alu = ALU.new
    alu.c0 = 0
    alu.c1 = 0
    alu.c2 = 0

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
    alu.c1 = 0
    alu.c2 = 0

    x = alu.x
    y = alu.y
    z = alu.z

    1000.times do
      x.read = 1
      y.read = 1
      x.write = 0
      y.write = 0

      x.bus_read Array.new(24, 0)
      y.bus_read Array.new(24, 0)

      x_val =  Random.rand(2**23)
      y_val =  Random.rand(2**23)
      z_val =  (x_val + y_val).to_bin_ary
      z_val << 0 until z_val.length == 24
 
      x.bus_read x_val.to_bin_ary
      y.bus_read y_val.to_bin_ary

      alu.clk
      x.read = 0
      y.read = 0
      z.read = 0
      z.write = 1
      x.write = 1
      y.write = 1

      assert_equal z_val, z.bus_write
      assert_equal x_val, x.bus_write.bin_to_dez
      assert_equal y_val, y.bus_write.bin_to_dez
    end

  end

  def test_rotate
    alu = ALU.new
    alu.c0 = 0
    alu.c1 = 1
    alu.c2 = 0

    x = alu.x
    y = alu.y
    z = alu.z

    1000.times do
      x.read = 1
      y.read = 1
      x.write = 0
      y.write = 0

      x.bus_read Array.new(24, 0)
      y.bus_read Array.new(24, 0)

      x_val =  Random.rand(2**24)
      y_val =  Random.rand(2**24)
      z_val =  x_val.to_bin_ary
      z_val << 0 until z_val.length == 24
      z_val = [z_val[23]] + z_val[0, 23]
 
      x.bus_read x_val.to_bin_ary
      y.bus_read y_val.to_bin_ary

      alu.clk
      x.read = 0
      y.read = 0
      z.read = 0
      z.write = 1
      x.write = 1
      y.write = 1

      assert_equal z_val, z.bus_write
      assert_equal x_val, x.bus_write.bin_to_dez
      assert_equal y_val, y.bus_write.bin_to_dez
    end

  end

  def test_and
    alu = ALU.new
    alu.c0 = 1
    alu.c1 = 1
    alu.c2 = 0

    x = alu.x
    y = alu.y
    z = alu.z

    1000.times do
      x.read = 1
      y.read = 1
      x.write = 0
      y.write = 0

      x.bus_read Array.new(24, 0)
      y.bus_read Array.new(24, 0)

      x_val =  Random.rand(2**24)
      y_val =  Random.rand(2**24)
      z_val =  (x_val & y_val).to_bin_ary
      z_val << 0 until z_val.length == 24
 
      x.bus_read x_val.to_bin_ary
      y.bus_read y_val.to_bin_ary

      alu.clk
      x.read = 0
      y.read = 0
      z.read = 0
      z.write = 1
      x.write = 1
      y.write = 1

      assert_equal z_val, z.bus_write
      assert_equal x_val, x.bus_write.bin_to_dez
      assert_equal y_val, y.bus_write.bin_to_dez
    end

  end

  def test_or
    alu = ALU.new
    alu.c0 = 0
    alu.c1 = 0
    alu.c2 = 1

    x = alu.x
    y = alu.y
    z = alu.z

    1000.times do
      x.read = 1
      y.read = 1
      x.write = 0
      y.write = 0

      x.bus_read Array.new(24, 0)
      y.bus_read Array.new(24, 0)

      x_val =  Random.rand(2**24)
      y_val =  Random.rand(2**24)
      z_val =  (x_val | y_val).to_bin_ary
      z_val << 0 until z_val.length == 24
 
      x.bus_read x_val.to_bin_ary
      y.bus_read y_val.to_bin_ary

      alu.clk
      x.read = 0
      y.read = 0
      z.read = 0
      z.write = 1
      x.write = 1
      y.write = 1

      assert_equal z_val, z.bus_write
      assert_equal x_val, x.bus_write.bin_to_dez
      assert_equal y_val, y.bus_write.bin_to_dez
    end

  end

  def test_xor
    alu = ALU.new
    alu.c0 = 1
    alu.c1 = 0
    alu.c2 = 1

    x = alu.x
    y = alu.y
    z = alu.z

    1000.times do
      x.read = 1
      y.read = 1
      x.write = 0
      y.write = 0

      x.bus_read Array.new(24, 0)
      y.bus_read Array.new(24, 0)

      x_val =  Random.rand(2**24)
      y_val =  Random.rand(2**24)
      z_val =  (x_val ^ y_val).to_bin_ary
      z_val << 0 until z_val.length == 24
 
      x.bus_read x_val.to_bin_ary
      y.bus_read y_val.to_bin_ary

      alu.clk
      x.read = 0
      y.read = 0
      z.read = 0
      z.write = 1
      x.write = 1
      y.write = 1

      assert_equal z_val, z.bus_write
      assert_equal x_val, x.bus_write.bin_to_dez
      assert_equal y_val, y.bus_write.bin_to_dez
    end

  end

  def test_not
    alu = ALU.new
    alu.c0 = 0
    alu.c1 = 1
    alu.c2 = 1

    x = alu.x
    y = alu.y
    z = alu.z

    1000.times do
      x.read = 1
      y.read = 1
      x.write = 0
      y.write = 0

      x.bus_read Array.new(24, 0)
      y.bus_read Array.new(24, 0)

      x_val =  Random.rand(2**24)
      y_val =  Random.rand(2**24)
      z_val =  x_val.to_bin_ary
      z_val << 0 until z_val.length == 24
      z_val.map!{|e| (e == 1) ? 0 : 1 }
 
      x.bus_read x_val.to_bin_ary
      y.bus_read y_val.to_bin_ary

      alu.clk
      x.read = 0
      y.read = 0
      z.read = 0
      z.write = 1
      x.write = 1
      y.write = 1

      assert_equal z_val, z.bus_write
      assert_equal x_val, x.bus_write.bin_to_dez
      assert_equal y_val, y.bus_write.bin_to_dez
    end

  end

  def test_eql
    alu = ALU.new
    alu.c0 = 1
    alu.c1 = 1
    alu.c2 = 1

    x = alu.x
    y = alu.y
    z = alu.z

    1000.times do
      x.read = 1
      y.read = 1
      x.write = 0
      y.write = 0

      x.bus_read Array.new(24, 0)
      y.bus_read Array.new(24, 0)

      x_val =  Random.rand(2**24)
      y_val =  Random.rand(2**24)
      z_val =  (x_val == y_val) ? [1]*24 : [0]*24
 
      x.bus_read x_val.to_bin_ary
      y.bus_read y_val.to_bin_ary

      alu.clk
      x.read = 0
      y.read = 0
      z.read = 0
      z.write = 1
      x.write = 1
      y.write = 1

      assert_equal z_val, z.bus_write
      assert_equal x_val, x.bus_write.bin_to_dez
      assert_equal y_val, y.bus_write.bin_to_dez
    end

    1000.times do
      x.read = 1
      y.read = 1
      x.write = 0
      y.write = 0

      x.bus_read Array.new(24, 0)
      y.bus_read Array.new(24, 0)

      x_val =  Random.rand(2**24)
      y_val =  x_val
      z_val =  (x_val == y_val) ? [1]*24 : [0]*24
 
      x.bus_read x_val.to_bin_ary
      y.bus_read y_val.to_bin_ary

      alu.clk
      x.read = 0
      y.read = 0
      z.read = 0
      z.write = 1
      x.write = 1
      y.write = 1

      assert_equal z_val, z.bus_write
      assert_equal x_val, x.bus_write.bin_to_dez
      assert_equal y_val, y.bus_write.bin_to_dez
    end

  end

end
