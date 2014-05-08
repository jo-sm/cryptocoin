module Cryptocoin
  module Protocol
    class VarLenInt < Integer
      def initialize(raw)
        # Generally, this will be fed a piece of data of which the length is not known
        # That is, the actual complete variable length integer will be sent with data appended
        head = raw.read(1).unpack('C')[0]
        @i = case @head
        when 0xfd
          raw_i = raw.read(2)
          raw_i.unpack('v')[0]
        when 0xfe
          raw_i = raw.read(4)
          raw_i.unpack('V')[0]
        when 0xff
          raw_i = raw.read(8)
          raw_i.unpack('Q')[0]
        else
          head
        end

        @head = head
        @body = raw_i
      end

      def to_i
        @i
      end

      def head
        @head
      end

      def body
        @body
      end

      def raw
        @head + @body
      end
    end
  end
end
