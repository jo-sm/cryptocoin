module Cryptocoin
  module Protocol
    class Message
      class Pong
        def self.parse_from_raw(payload)
          nonce = payload
          self.new(nonce)
        end
        
        def initialize(nonce)
          @nonce_raw = nonce
        end
        
        def nonce
          @nonce ||= @nonce_raw.unpack('Q')[0]
        end
        
        def raw
          @nonce_raw
        end
      end
    end
  end
end