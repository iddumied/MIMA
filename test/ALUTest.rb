require './lib/MIMA.rb'
require 'test/unit'

class ALUTest < Test::Unit::TestCase
  
  include MIMA
  
  def test_add
    alu = ALU.new
    x = alu.x
    y = alu.y
    z = alu.z

    x.read = 1
    y.read = 1

    x.bus_read [1,0,1]
    y.bus_read [1,1]

    alu.c0 = 1

    puts alu.inspect
    puts x.inspect
    puts y.inspect
    puts alu.clk.inspect

    z.write = 1

    assert_equal [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0], z.bus_write

  end

end
