require 'digest/sha2'
require 'cryptocoin/protocol/message'

module Cryptocoin
  module Protocol
    class Packet
      attr_reader :message, :network
      
      def self.parse_from_raw(raw)
        magic = raw[0..4]
        command = raw[5..16]
        payload_length = raw[17..20]
        payload_checksum = raw[21..24]
        payload = raw[25..-1]
        message = Cryptocoin::Protocol::Message.parse(command, payload)
      end
      
      def self.parse_from_io
        magic = io.read(4)
        command = io.read(12)
        payload_length = io.read(4)
        payload_checksum = io.read(4)
        payload = io.read
        message = Cryptocoin::Protocol::Message.parse(command, payload)
      end
      
      def initialize(magic, command, payload_length, payload_checksum, message, network)
        @magic_raw = magic
        @command_raw = command
        @payload_length_raw = payload_length
        @payload_checksum_raw = payload_checksum
        @message = message
        @network = network
      end
      
      def magic
        @magic_raw.unpack('L')[0]
      end
      
      def command
        @command_raw.unpack('a*')[0]
      end
      
      def payload_length
        @payload_length_raw.unpack('L')[0]
      end
      
      def payload_checksum
        @payload_checksum_raw.unpack('L')[0]
      end

      def valid?
        valid_checksum and valid_magic and valid_message
      end
      
      def raw
        @magic_raw + @command_raw + @payload_length_raw + @payload_checksum_raw + @message.raw
      end

      private
      def valid_checksum
        Cryptocoin::Digest.new(@message.raw, :binary).sha256[0..4] == @payload_checksum_raw
      end

      def valid_magic
        magic == network.magic
      end

      def valid_message
        @message.valid?
      end
    end
  end
end
