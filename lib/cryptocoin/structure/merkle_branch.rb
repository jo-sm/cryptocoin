require 'cryptocoin/protocol/var_len_int'

module Cryptocoin
	module Structure
    class MerkleBranch
      def self.parse_from_io(io)
        branch_length = Cryptocoin::Protocol::VarLenInt.parse_from_io(io)

        branch_hashes = branch_length.times.map { |i|
          io.read(32)
        }

        branch_side_mark = io.read(4)

        self.new(branch_length, branch_hashes, branch_side_mark)
      end

      def initialize(branch_length, branch_hashes, branch_side_mark)
        @branch_length_raw = branch_length
        @branch_hashes_raw = branch_hashes
        @branch_side_mark_raw = branch_side_mark
      end

      def branch_length
        @branch_length ||= @branch_length_raw.to_i
      end

      def branch_hashes
        @branch_hashes ||= @branch_hashes_raw.map { |branch_hash| branch_hash.reverse.unpack('H*')[0] }
      end

      def branch_side_mark
        @branch_side_mark ||= @branch_side_mark_raw.unpack('l')[0]
      end
    end
  end
end