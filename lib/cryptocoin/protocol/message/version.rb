module Cryptocoin
  module Protocol
    class Message
      class Version
        def self.parse_from_raw(payload)
          version = payload[0..3]
          services = payload[4..11]
          timestamp = payload[12..19]
          address_received = Cryptocoin::Protocol::NetAddr.parse_from_raw(payload[20..45])
          address_from = Cryptocoin::Protocol::NetAddr.parse_from_raw(payload[46..71])
          nonce = payload[71..79]
          user_agent = Cryptocoin::Protocol::VarLenStr.parse_from_raw(payload[80..-1])
          start_height = payload[-5..-2]
          relay = payload[-1]
        end
        
        def initialize(version, services, timestamp, address_received, address_from, nonce, user_agent, start_height, relay)
          @version_raw = version
          @services_raw = services
          @timestamp_raw = timestamp
          @address_received = address_received
          @address_from = address_from
          @nonce_raw = nonce
          @user_agent = user_agent
          @start_height_raw = start_height
          @relay_raw = relay
        end
        
        def version
          @version ||= @version_raw.unpack('l')[0]
        end
        
        def services
          @services ||= @services_raw.unpack('Q')[0]
        end
        
        def timestamp
          @timestamp ||= @timestamp_raw.unpack('q')[0]
        end
        
        def nonce
          @nonce ||= @nonce_raw.unpack('Q')[0]
        end
        
        def start_height
          @start_height ||= @start_height_raw.unpack('l')[0]
        end
        
        def relay
          @relay ||= @relay_raw.unpack('c')[0]
        end 
        
        def raw
          @version_raw + @services_raw + @timestamp_raw + @address_received.raw + @address_from.raw + @nonce_raw + @user_agent.raw + @start_height_raw + @relay_raw
        end
      end
    end
  end
end