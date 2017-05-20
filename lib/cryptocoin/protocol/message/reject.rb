require 'cryptocoin/protocol/var_len_str'

module Cryptocoin
  module Protocol
    class Message
      class Reject
        attr_reader :message, :reason
        
        def self.parse_from_raw(payload)
          message = Cryptocoin::Protocol::VarLenStr.parse_from_raw(payload)
          c = message.raw.bytesize
          ccode = payload[c..c]
          reason = Cryptocoin::Protocol::VarLenStr.parse_from_raw(payload[c+1..-1])
          self.new(message, ccode, reason)
        end
        
        def initialize(message, ccode, reason)
          @message = message
          @ccode_raw = ccode
          @reason = reason
        end
        
        def ccode
          @ccode ||= @ccode_raw.unpack('H*')[0]
        end
        
        def ccode_name
          case ccode
          when '1'
            'REJECT_MALFORMED'
          when '10'
            'REJECT_INVALID'
          when '11'
            'REJECT_OBSOLETE'
          when '12'
            'REJECT_DUPLICATE'
          when '40'
            'REJECT_NONSTANDARD'
          when '41'
            'REJECT_DUST'
          when '42'
            'REJECT_INSUFFICIENTFEE'
          when '43'
            'REJECT_CHECKPOINT'
          end
        end
        
        def raw
          @message.raw + @ccode_raw + @reason.raw
        end
      end
    end
  end
end