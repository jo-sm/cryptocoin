module Cryptocoin
  module Protocol
    class Message
      class Getaddr
        def parse_from_raw(payload)
          # https://en.bitcoin.it/wiki/Protocol_specification#getaddr
          # This message has no payload
          self.new
        end
        
        def raw
          nil
        end
      end
    end
  end
end