require 'cryptocoin/protocol/var_len_int'

module Cryptocoin
  module Structure
    class Transaction
      class Output
        def initialize(raw)
          _begin = raw.pos
          @value_raw = raw.read(8)
          @value = @value_raw.unpack('Q')[0]
          @pk_script_length = Cryptocoin::Protocol::VarLenInt.new(raw)
          @pk_script = raw.read(@pk_script_length)
          _end = raw.pos
          @size = _end - _begin
        end

        def raw
          @value_raw + @pk_script_length.raw + @pk_script
        end
      end
    end
  end
end
