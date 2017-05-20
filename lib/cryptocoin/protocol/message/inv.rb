require 'cryptocoin/protocol/inventory_vector'
require 'cryptocoin/protocol/var_len_int'

module Cryptocoin
  module Protocol
    class Message
      class Inv
        def self.parse_from_raw(payload)
          inventory = []
          i = 0
          count = Cryptocoin::Protocol::VarLenInt.parse_from_raw(payload)
          count.times do
            c = count.raw.bytesize+i*36
            inventory.push(Cryptocoin::Protocol::InventoryVector.parse_from_raw(payload[c..c+35]))
            i+=1
          end
          self.new(count, inventory)
        end
        
        def initialize(count, inventory)
          @count_raw = count
          @inventory = inventory
        end
        
        def raw
          @count_raw + @inventory.map{|e| e.raw}.join
        end
      end
    end
  end
end