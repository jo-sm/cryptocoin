require 'cryptocoin/script'
require 'cryptocoin/protocol/var_len_int'

module Cryptocoin
  module Structure
    class Transaction
      class Output
        attr_reader :index, :value, :pk_script_length, :pk_script
        
        def self.parse_from_io(i, io)
          value_raw = io.read(8)
          puts "CURRENT IO POS: #{io.pos}"
          pk_script_length = Cryptocoin::Protocol::VarLenInt.parse_from_io(io)
          pk_script_raw = io.read(pk_script_length.to_i)
          self.new(value_raw, pk_script_length, pk_script_raw, i)
        end
        
        def initialize(value_raw, pk_scipt_length, pk_script_raw, i)
          @value_raw = value_raw
          @pk_script_length = pk_script_length
          @pk_script_raw = pk_script_raw
          @index = i
        end
        
        def value
          @value_raw.unpack('Q')[0]
        end
        
        def pk_script
          @pk_script ||= Cryptocoin::Script.new(@pk_script_raw)
        end

        def raw
          @value_raw + @pk_script_length.raw + @pk_script
        end
        
        def copy
          r = self
          ['value_raw', 'pk_script_length', 'pk_script_raw', 'index'].each do |i|
            r.class.send(:define_method, "#{i}=") do |j|
              instance_variable_set("@#{i}", j)
            end
          end
          r
        end
      end
    end
  end
end
