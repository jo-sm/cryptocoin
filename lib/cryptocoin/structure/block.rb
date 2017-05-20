require 'cryptocoin/structure/transaction'
require 'cryptocoin/protocol/var_len_int'
require 'stringio'

module Cryptocoin
  module Structure
    class Block
      attr_reader :transactions_count, :transactions
      def self.parse_from_raw(raw)
        io = StringIO.new(raw)
        self.parse_from_io(io)
      end
      
      def self.parse_from_io(io, is_aux_pow=false)
        # Save file for future use
        # File.open('block.dat', 'w') do |f|
        #   f.puts(io.read)
        #   io.seek(0)
        # end
        txs = []
        version_raw = io.read(4)
        prev_block_raw = io.read(32)
        merkle_root_raw = io.read(32)
        timestamp_raw = io.read(4)
        bits_raw = io.read(4)
        nonce_raw = io.read(4)

        if is_aux_pow 
          # TODO: actually save this information
          aux_coinbase_tx = Cryptocoin::Structure::Transaction.parse_from_io(io)
          aux_block_hash = io.read(32)
          aux_coinbase_branch = Cryptocoin::Structure::MerkleBranch.parse_from_io(io)
          aux_blockchain_branch = Cryptocoin::Structure::MerkleBranch.parse_from_io(io)
          aux_parent_block = io.read(80) #This is a block header, parse this later
        end

        tx_count = Cryptocoin::Protocol::VarLenInt.parse_from_io(io)
        p "Transaction count: #{tx_count}, #{tx_count.to_i}"
        tx_count.times do
          txs.push(Cryptocoin::Structure::Transaction.parse_from_io(io))
        end
        self.new(version_raw, prev_block_raw, merkle_root_raw, timestamp_raw, bits_raw, nonce_raw, tx_count, txs)
      end
      
      # txs is an array to keep consistent with the transaction model
      def initialize(version_raw, prev_block_raw, merkle_root_raw, timestamp_raw, bits_raw, nonce_raw, tx_count, txs)
        @version_raw = version_raw
        @prev_block_raw = prev_block_raw
        @merkle_root_raw = merkle_root_raw
        @timestamp_raw = timestamp_raw
        @bits_raw = bits_raw
        @nonce_raw = nonce_raw
        @transactions_count = tx_count
        @transactions = txs
      end

      def head
        @version_raw + @prev_block_raw + @merkle_root_raw + @timestamp_raw + @bits_raw + @nonce_raw
      end

      def body
        @transactions_count.raw + @transactions.reduce { |tx, memo| memo += tx }
      end
      
      def version
        @version ||= @version_raw.unpack('L')[0]
      end
      
      def previous_block_digest
        @previous_block_digest ||= @prev_block_raw.reverse.unpack('H*')[0]
      end
      
      def merkle_root_digest
        @merkle_root_digest ||= @merkle_root_raw.reverse.unpack('H*')[0]
      end
      
      def timestamp
        @timestamp ||= @timestamp_raw.unpack('L')[0]
      end
      
      def bits
        @bits ||= @bits_raw.unpack('L')[0]
      end
      
      def target
        require 'openssl'
        @bytes if @bytes

        puts @bits_raw.unpack('H*')[0]

        bytes = OpenSSL::BN.new(@bits_raw.unpack('H*')[0].reverse_every(2), 16).to_s(0).unpack('C*')
        size = bytes.size - 4
        nbits = size << 24
        nbits |= (bytes[4] << 16) if size >= 1
        nbits |= (bytes[5] <<  8) if size >= 2
        nbits |= (bytes[6]      ) if size >= 3
        @bytes = nbits
      end
      
      def nonce
        @nonce ||= @nonce_raw.unpack('L')[0]
      end

      def digest
        @digest ||= Cryptocoin::Digest.new(self.head, :binary).double_sha256.reverse_every(2)
      end
    end
  end
end
