module Cryptocoin
  module Protocol
    class VarLenInt
      # https://github.com/andrew12/bitcoin-ruby/blob/master/lib/bitcoin.rb#L132
      # TODO: test this implementation
      def self.from_int(i)
        if i < -0xffffffffffffffff
          return ArgumentError, "Unrepresentable"
        elsif i < 0
          top_32 = ((-i) & 0xffffffff00000000) >> 32
          btm_32 = (-i) & 0x00000000ffffffff
          return self.new([0xff, top_32, btm_32].pack("CVV"))
        elsif i <= 0xfc
          return self.new([i].pack('C'))
        elsif i <= 0xffff
          return self.new([0xfd, i].pack("Cv"))
        elsif i <= 0xffffffff
          return self.new([0xfe, i].pack("CV"))
        else
          return ArgumentError, "Unrepresentable"
        end
      end

      def self.parse_from_io(io)
        i = io.read(1)
        j = i.unpack('C')[0]
        case j
        when 0xfd
          self.new(i + io.read(2))
        when 0xfe
          self.new(i + io.read(4))
        when 0xff
          self.new(i + io.read(8))
        else
          puts "Something: #{i}"
          self.new(i)
        end
      end

      def initialize(raw)
        @head_raw = raw[0]
        @head = @head_raw.unpack('C')[0]
        @body = case @head
        when 0xfd
          @raw_i = raw[1..3]
          @raw_i.unpack('v')[0]
        when 0xfe
          @raw_i = raw[1..5]
          @raw_i.unpack('V')[0]
        when 0xff
          @raw_i = raw[1..9]
          @raw_i.unpack('Q')[0]
        else
          @raw_i = @head_raw
          @head
        end
      end

      def to_i
        @body
      end

      def head
        @head
      end

      def body_raw
        @raw_i
      end

      def body
        @body
      end

      def raw
        @head_raw + (@raw_i == @head_raw ? '' : @raw_i)
      end

      def method_missing(name, *args, &block)
        ret = body.send(name, *args, &block)
        ret
      end
    end
  end
end
