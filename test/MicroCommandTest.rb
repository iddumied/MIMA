require './lib/MIMA.rb'
require 'test/unit'

class MicroCommandTest < Test::Unit::TestCase
  
  include MIMA
  WRITE = ControlUnit::MicroCommand::WRITE
  READ  = ControlUnit::MicroCommand::READ
  ALU_FLAGS = ControlUnit::MicroCommand::ALU_FLAGS
  FLAGS = ControlUnit::MicroCommand::FLAGS
  
  def test_parse_decode

    1000.times do
      write = WRITE.keys[Random.rand(WRITE.length)]
      reads = []
      Random.rand(READ.length).times do 
        reads << READ.keys[Random.rand(READ.length)]
      end
      reads.uniq!

      alu = ALU_FLAGS.keys[Random.rand(ALU_FLAGS.length)]
      flag = FLAGS.keys[Random.rand(FLAGS.length)]
      addr = []
      8.times { addr << Random.rand(2) }

      str = ""
      reads.each do |r|
        str += "#{ write } -> #{ r }; "
      end

      str += "ALU #{ alu }; #{ flag } = 1; ADR #{ addr.bin_to_hex };"
      res = ControlUnit::MicroCommand.new(ControlUnit::MicroCommand.new(str).bits).description
      msg = "src: #{ str }\ndst: #{ res }"

      res.split(";").each do |comand|
        comand = comand.reverse.chop.reverse if comand.start_with? " "
        if str.include? comand
          assert(true, msg)
        else
          assert(false, msg +  "\n#{ comand }")
        end
      end

    end
  end

end
