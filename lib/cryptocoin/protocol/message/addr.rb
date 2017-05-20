require 'cryptocoin/protocol/var_len_int'
require 'cryptocoin/protocol/net_addr'

module Cryptocoin
  module Protocol
    class Message
      class Addr
        attr_reader :count, :addresses
        def parse_from_raw(payload)
          count = Cryptocoin::Protocol::VarLenInt.parse_from_raw(payload)
          addresses = []
          count.times do
            addresses.push(Cryptocoin::Protocol::NetAddr.parse_from_raw(payload[@count.raw.bytesize + 30*@addresses.count]))
          end
          self.new(count, addresses)
        end
        
        def initialize(count, addresses)
          @count = count
          @addresses = addresses
        end
        
        def raw
          @count.raw + @addresses.map{|e| e.raw}.join
        end
      end
    end
  end
end