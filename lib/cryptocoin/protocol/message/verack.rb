module Cryptocoin
  module Protocol
    class Message
      class Verack
        def self.parse_from_raw(payload)
          # https://en.bitcoin.it/wiki/Protocol_specification#verack
          # Has no payload
          self.new
        end        
        def raw
          nil
        end
      end
    end
  end
end