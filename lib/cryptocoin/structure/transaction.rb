require 'cryptocoin/structure/transaction/input'
require 'cryptocoin/structure/transaction/output'
require 'cryptocoin/protocol/var_len_int'

module Cryptocoin
  module Structure
    class Transaction
      def initialize(raw)
        _begin = raw.pos
        @version_raw = raw.read(4)
        @version = @version_raw..unpack('V')[0]
        @in_length = Cryptocoin::Protocol::VarLenInt.new(raw)
        @in_length.times do
          @inputs << Cryptocoin::Structure::Transaction::Input.new(raw)
        end

        @out_length = Cryptocoin::Protocol::VarLenInt.new(raw)
        @out_length.times do
          @outputs << Cryptocoin::Structure::Transaction::Output.new(raw)
        end
        @lock_time_raw = raw.read(4)
        @lock_time = @lock_time_raw.unpack('V')[0]
        _end = raw.pos
        @size = _end - _begin
      end
    end
  end
end
