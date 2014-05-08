require 'digest/sha2'
require 'cryptocoin/protocol/message'

module Cryptocoin
  module Protocol
    class Packet
      def initialize(raw)
        # Parse the raw message and see what's going on
        @magic = raw.read(4).unpack('a')[0]
        @command = raw.read(12).unpack('A')[0]
        @payload_length = raw.read(4).unpack('V')[0]
        @payload_checksum = raw.read(4).unpack('a')[0]
        @payload = raw.read(payload_length)
        @message = Cryptocoin::Protocol::Message.new(@command, @payload)
      end

      def valid?
        valid_checksum and valid_magic and valid_message
      end

      private
      def valid_checksum
        Digest::SHA256.digest(Digest::SHA256.digest(@payload))[0...4] == @payload_checksum
      end

      def valid_magic
        return true
        # TODO: Add configurable network magic
        #@magic == 
      end

      def valid_message
        @message.valid?
      end
    end
  end
end
