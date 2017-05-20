require 'cryptocoin/protocol/block_header'

module Cryptocoin
  module Protocol
    class Message
      class Headers
        attr_reader :count, :headers
        def self.parse_from_raw(payload)
          headers, i = [], 0
          count = Cryptocoin::Protocol::VarLenInt.parse_from_raw(payload)
          count.times do
            c = count.raw.bytesize + i*81
            headers.push(Cryptocoin::Protocol::BlockHeader.parse_from_raw(payload[c..c+80]))
            i+=1
          end
          self.new(count, headers)
        end
        
        def initialize(count, headers)
          @count = count
          @headers = headers
        end
        
        def raw
          @count.raw + @headers.map{|e| e.raw}.join
        end
      end
    end
  end
end