require 'cryptocoin/protocol/var_len_int'

module Cryptocoin
  module Protocol
    class VarLenStr < String
      def initialize(raw)
        @size = Cryptocoin::Protocol::VarLenInt.new(raw)
        @str = raw.read(@size)
      end
      def size
        @size
      end
      def to_s
        @str
      end
    end
  end
end
