require 'cryptocoin/script/op_code/constants'
require 'cryptocoin/script/op_code/functions'

module Cryptocoin
  # Script, or as I prefer to stylize it, SCRIPT, is Satoshi's
  # non-Turing complete scripting language for Bitcoin transactions
  # It's similar to Forth and Postscript in that it's a stack based
  # language, while missing certain features such as loops to prevent
  # malicious code from being created within a transaction. 
  #
  # This is the parser for a SCRIPT directive
  class Script
    include Cryptocoin::Script::OpCode::Constants
    include Cryptocoin::Script::OpCode::Functions
    
    # Create binary script from string
    def self.from_s(str)
      
    end
    # Validates that the script is okay within the ruleset of the
    # Bitcoin protocol
    def initialize(directive, subscript=false)
      return false if directive.length > 10000
      @directive = directive
      @transaction_valid = true
      @valid = parse
      @subscript = subscript
    end

    # Parses directive according to current Bitcoin client rules
    # Returns true if a valid script, returns valid is invalid
    def parse
      j = 0
      @stack, @alt_stack, @exec_stack = [], [], []
      # Now we have the Integer representations of each hex value, which can be used without problem
      while !@directive.eof?
        @j+=1
        @_i = @directive.read(1)
        # if subscript, skip this byte and delete it from the resulting script
        op_code = Cryptocoin::Script::Opcode.new(@_i)
        return false if !op_code.valid?
        return false if j > 201 and op_code.hex > OP_16
        return false if op_code.disabled?
        v = case op_code.hex
        when OP_PUSHDATA0..OP_PUSHDATA4
          op_pushdata
        when OP_1NEGATE or OR_1 or OP_2..OP_16
          op_numeric
        when [OP_NOP, OP_NOP1..OP_NOP10].include?(@_i)
          next
        when OP_IF or OP_NOTIF
          op_if
        when OP_ELSE
          op_else
        when OP_ENDIF
          op_endif
        when OP_RETURN
          op_return
        end

        return false if !v
      end
      # if top of stack is truthy, true
      # else, false
      return true if @stack.last.to_openssl_bn_int.to_bool
      false
    end

    def valid?
      @valid
    end

    def subscript?
      @subscript
    end

    def transaction_valid?
      @transaction_valid
    end
  end
end
