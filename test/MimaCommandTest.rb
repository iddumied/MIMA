require './lib/MIMA.rb'
require 'test/unit'

class MicroCommandTest < Test::Unit::TestCase
  
  include MIMA
  
  def test_short_commands
    1000.times do
      comand = MimaCommand::SCOMMANDS.values[Random.rand(MimaCommand::SCOMMANDS.length)]
      next if comand == "LC"

      addr = []
      addr << Random.rand(2) until addr.length == 20
      comand = "#{ comand } #{ addr.bin_to_hex }"

      assert_equal comand, MimaCommand.new(MimaCommand.new(comand).bits).description
    end
  end

  def test_long_commands
    1000.times do
      comand = MimaCommand::LCOMMANDS.values[Random.rand(MimaCommand::LCOMMANDS.length)]

      assert_equal comand, MimaCommand.new(MimaCommand.new(comand).bits).description
    end
  end

  def test_alu_comands
    mima = Mima.new

    1000.times do
      x, y, addr = [], [], []
      20.times { x << Random.rand(2); y << Random.rand(2); addr << Random.rand(2) }

      mima.run "LDC #{ x.bin_to_hex }"
      mima.run "STV #{ addr.bin_to_hex }"

      mima.run "LDC #{ y.bin_to_hex }"
      mima.run "ADD #{ addr.bin_to_hex }"
      assert_equal mima.akku.content.bin_to_dez, (x.bin_to_dez + y.bin_to_dez) 

      mima.run "LDC #{ y.bin_to_hex }"
      mima.run "AND #{ addr.bin_to_hex }"
      puts "[DEBUG] #{ y.bin_to_dez } | #{ x.bin_to_dez } = #{ y.bin_to_dez | x.bin_to_dez }"
      puts "[DEBUG] #{ y.bin_to_dez } & #{ x.bin_to_dez } = #{ y.bin_to_dez & x.bin_to_dez }"
      assert_equal mima.akku.content.bin_to_dez, (x.bin_to_dez & y.bin_to_dez) 

      mima.run "LDC #{ y.bin_to_hex }"
      mima.run "OR #{ addr.bin_to_hex }"
      assert_equal mima.akku.content.bin_to_dez, (x.bin_to_dez | y.bin_to_dez) 

      mima.run "LDC #{ y.bin_to_hex }"
      mima.run "XOR #{ addr.bin_to_hex }"
      assert_equal mima.akku.content.bin_to_dez, (x.bin_to_dez ^ y.bin_to_dez) 
    end
  end

end
