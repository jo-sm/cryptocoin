module Cryptocoin
  module Protocol
    class Message
      class Mempool
        def self.parse_from_raw(payload)
          # https://en.bitcoin.it/wiki/Protocol_specification#mempool
          # No data is sent with this message
          self.new
        end        
        def raw
          nil
        end
      end
    end
  end
end