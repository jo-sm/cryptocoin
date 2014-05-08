require 'cryptocoin/structure/transaction'

module Cryptocoin
  module Structure
    class Block
      attr_reader :raw, :hash, :prev_block_hash, :transactions, :merkle_root, :timestamp, :bits, :nonce, :version, :payload, :header

      def initialize(raw)
        @payload = raw
        @head = raw.read(80)
        @body = raw.read
        
        @version, @previous_block, @merkle_root, @timestamp, @bits, @nonce = head.unpack("Va32a32VVV")

        until @body.eof?
          @transactions = Cryptocoin::Structure::Transaction.new(@body)
        end
      end

      private

      attr_writer :raw, :hash, :prev_block_hash, :transactions, :merkle_root, :timestamp, :bits, :nonce, :version, :payload, :header
    end
  end
end
