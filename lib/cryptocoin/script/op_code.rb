require 'cryptocoin/script/op_code/constants'

module Cryptocoin
  class Script
    # Taken from the Bitcoin official client
    class OpCode
      include Cryptocoin::Script::OpCode::Constants
      def self.from_name(name)
        c = Cryptocoin::Script::OpCode::Constants.const_get(name.upcase)
        self.new([c].pack('C'))
      rescue NameError 
        false
      end

      def initialize(bin)
        @bin = bin
        @hex = bin.unpack('H*')[0].to_i(16)

        if const_by_val(@hex) or @hex.between?(OP_PUSHDATA0, OP_PUSHDATA1)
          @valid = true
        else
          @valid = false
        end
      end
      
      def name
        # Return special case first 
        return nil if !@valid
        return 'OP_PUSHDATA0' if @hex.between?(OP_PUSHDATA0, OP_PUSHDATA1)
        const_by_val(hex).to_s
      end

      def hex
        @hex
      end

      def raw
        @bin
      end

      def valid?
        @valid
      end

      def disabled?
        return nil if !@valid
        [OP_CAT, OP_SUBSTR, OP_LEFT, OP_RIGHT, OP_INVERT, OP_AND, OP_OR, OP_XOR, OP_2MUL, OP_2DIV, OP_MUL, OP_DIV, OP_MOD, OP_LSHIFT, OP_RSHIFT].include?(@hex)
      end

      private

      def const_by_val(val)
        Cryptocoin::Script::OpCode::Constants.constants.find{ |name|
          Cryptocoin::Script::OpCode::Constants.const_get(name) == val
        }
      end
    end
  end
end
