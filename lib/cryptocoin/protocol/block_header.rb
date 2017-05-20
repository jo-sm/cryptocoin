require 'cryptocoin/protocol/var_len_int'

module Cryptocoin
  module Protocol
    class BlockHeader
      attr_reader :transaction_count
      
      def self.parse_from_raw(raw)
        version = raw[0..3]
        previous_block_digest = raw[4..35]
        merkle_root_digest = raw[36..67]
        timestamp = raw[68..71]
        bits = raw[72..75]
        nonce = raw[76..79]
        tx_count = Cryptocoin::Protocol::VarLenInt.parse_from_raw(raw[80..-1])
        self.new(version, previous_block_digest, merkle_root_digest, timestamp, bits, nonce, tx_count)
      end
      
      def initialize(version, previous_block_digest, merkle_root_digest, timestamp, bits, nonce, tx_count)
        @version_raw = version
        @previous_block_digest_raw = previous_block_digest
        @merkle_root_digest_raw = merkle_root_digest
        @timestamp_raw = timestamp
        @bits_raw = bits
        @nonce_raw = nonce
        @transaction_count = tx_count
      end
      
      def version
        @version ||= @version_raw.unpack('L')[0]
      end
      
      def previous_block_digest
        @previous_block_digest ||= @previous_block_digest_raw.unpack('H*')[0]
      end
      
      def merkle_root_digest
        @merkle_root_digest_raw ||= @merkle_root_digest_raw.unpack('H*')[0]
      end
      
      def timestamp
        @timestamp ||= @timestamp_raw.unpack('L')[0]
      end
      
      def bits
        @bits ||= @bits_raw.unpack('L')[0]
      end
      
      def nonce
        @nonce ||= @nonce_raw.unpack('L')[0]
      end
      
      def raw
        @version_raw + @previous_block_digest_raw + @merkle_root_digest_raw + @timestamp_raw + @bits_raw + @nonce_raw + @transaction_count.raw
      end
	  end
  end
end