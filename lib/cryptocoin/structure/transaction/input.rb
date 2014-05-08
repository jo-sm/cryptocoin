require 'cryptocoin/protocol/var_len_int'

module Cryptocoin
  module Structure
    class Transaction
      class Input
        def initialize(raw)
          _begin = raw.pos
          @previous_output_hash_raw = raw.read(32)
          @previous_output_hash = @previous_output_hash_raw.unpack('a*')
          @previous_output_index_raw = raw.read(4)
          @previous_output_index = @previous_output_index_raw.unpack('V')
          @script_sig_length = Cryptocoin::Protocol::VarLenInt.new(raw)
          @script_sig_raw = raw.read(@script_sig)
          @sequence = raw.read(4)
          _end = raw.pos
          @size = _end - _begin
        end

        def raw
          @previous_output_hash_raw + @previous_output_index_raw + @script_sig_length.raw + @script_sig_raw + @sequence
        end
      end
    end
  end
end
