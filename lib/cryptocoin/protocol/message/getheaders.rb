module Cryptocoin
  module Protocol
    class Message
      class Getheaders
        attr_reader :digest_count
        
        def parse_from_raw(payload)
          block_locator_digests, i = [], 0
          version = payload[0..3]
          digest_count = Cryptocoin::Protocol::VarLenInt.parse_from_raw(payload[4..-1])
          digest_count.times do
            c = digest_count.raw.bytesize+i*32
            block_locator_digests.push(payload[c..c+31])
            i+=1
          end
          digest_stop = payload[5+i*32..-1]
        end
        
        def initialize(version, digest_count, block_locator_digests, digest_stop)
          @version_raw = version
          @digest_count = digest_count
          @block_locator_digests_raw = block_locator_digests
          @digest_stop_raw = digest_stop
        end
        
        def version
          @version ||= @version_raw.unpack('L')[0]
        end
        
        def block_locator_digests
          @block_locator_digests ||= @block_locator_digests_raw.map{|e| e.unpack('H*')[0] }
        end
        
        def digest_stop
          @digest_stop ||= @digest_stop_raw.unpack('H*')[0]
        end
        
        def raw
          @version_raw + @digest_count.raw + @block_locator_digests_raw.join + @digest_stop_raw
        end
      end
    end
  end
end