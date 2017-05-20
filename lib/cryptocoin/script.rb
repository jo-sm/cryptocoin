require 'cryptocoin/script/op_code'
require 'cryptocoin/script/op_code/functions'

module Cryptocoin
  # Script, or as I prefer to stylize it, SCRIPT, is Satoshi's
  # non-Turing complete scripting language for Bitcoin transactions
  # It's similar to Forth and Postscript in that it's a stack based
  # language, while missing certain features such as loops to prevent
  # malicious code from being created within a transaction. 
  #
  # This is the parser for a SCRIPT directive
  #
  # My thinking behind the design of this parser is that, while it is
  # tied to transactions usually, it can be used to parse general statements
  # that a user inputs
  class Script
    include Cryptocoin::Script::OpCode::Constants
    include Cryptocoin::Script::OpCode::Functions
    
    attr_accessor :stack
    
    # Create binary script from string
    # Returns false if unable to create binary string
    def self.from_s(str)
      # split each value from str
      # look up value in constants
      # push data if pushdata instruction, noting that pushdata0 will need to read the binary size of the next string and then add the size plus the string
      instructions = str.split(' ')
      raw = ''
      instructions.each_index do |i|
        code = Cryptocoin::Script::OpCode.from_name(instructions[i].upcase)
        return false if !code
        case code.hex
        when OP_PUSHDATA0
          data = instructions.slice!(i+1)
          data = [data].pack('H*')
          raw += [data.bytesize].pack('C') + data
        when OP_PUSHDATA1..OP_PUSHDATA4
          # Crude implementation because it ignores what data says about the length
          bytes = instructions.slice!(i+1)
          data = instructions.slice!(i+1)
          raw += code.raw + [bytes].pack('H*') + [data].pack('H*')
        else
          raw += code.raw
        end
      end
      self.new(raw)
    end
    
    # Validates that the script is okay within the ruleset of the
    # Bitcoin protocol
    def initialize(raw)
      return false if raw.bytesize > 10000
      @script = raw
      @raw = raw
      @transaction_valid = true
      @valid = false
      @subscript = false
      @codeseparator = 0
      @script_string = []
      @stack = []
    end
        
    # Sets the script as subscript and parses it to remove
    # OP_CODESEPARATOR and the signature
    def is_subscript!(signature)
      @sub_sig = signature
      @subscript = true
    end
    
    def is_subscript?
      @subscript
    end
    
    # Sets the transaction so that it can be used if
    # OP_CHECKSIG is called within directive
    # +tx+ is the current transaction and +input+ is the 
    # current input index
    def set_transaction(tx, input)
      @transaction = tx
      @input_index = input
    end

    def raw
      if is_subscript?
        # Remove OP_CODESEPARTOR
        parse(true)
        # Remove signature
        @raw = @raw.split(@sub_sig).join
      end
      @raw
    end

    def to_s
      @script_string.join(' ')
    end

    # Parses directive according to current Bitcoin client rules
    # Returns true if a valid script, returns valid is invalid
    # The functions are also aware if it's subscript and don't
    # parse as much (i.e. we don't actually check the validity) 
    # if so.
    def parse!(is_subscript=false)
      opcode_count = 0
      @alt_stack, @exec_stack = [], [] # These stacks are not carried over
      seek = 0
      @raw = ""
      while seek < @script.length 
        opcode_count+=1
        _i = @script[seek]
        seek += 1
        opcode = Cryptocoin::Script::OpCode.new(_i)
        return false if !opcode.valid?
        return false if opcode_count > 201 and opcode.hex > OP_16
        return false if opcode.disabled?
        
        if is_subscript
          if !(opcode.hex == OP_CODESEPARATOR)
            @raw += _i
            @script_string.push(opcode.name)
          end
        else
          @raw += _i
          @script_string.push(opcode.name)
        end
                
        if opcode.hex.between?(OP_PUSHDATA0, OP_PUSHDATA4)
          @stack, @script_string, @raw, seek = op_pushdata(@stack, opcode, @script, @script_string, @raw, seek)
        end
        
        if !is_subscript?
          case opcode.hex
          when OP_1NEGATE, OP_1, OP_2..OP_16
            @stack = op_numeric(@stack, opcode)
          when OP_NOP, OP_NOP1..OP_NOP10
            op_nop
          when OP_IF, OP_NOTIF
            @stack, @exec_stack = op_if(@stack, @exec_stack, opcode)
          when OP_ELSE
            @exec_stack = op_else(@exec_stack)
          when OP_ENDIF
            exec_stack = op_endif(exec_stack)
          when OP_RETURN
            @transaction_valid = op_return
          when OP_CODESEPARATOR
            @codeseparator = op_codeseparator(seek)
          when OP_VERIFY
            @stack = op_verify(@stack)
          when OP_TOALTSTACK
            @stack, alt_stack = op_toaltstack(@stack, alt_stack)
          when OP_FROMALTSTACK
            @stack, alt_stack = op_fromaltstack(@stack, alt_stack)
          when OP_2DROP
            @stack = op_2drop(@stack)
          when OP_2DUP
            @stack = op_2dup(@stack)
          when OP_3DUP
            @stack = op_3dup(@stack)
          when OP_2OVER
            @stack = op_2over(@stack)
          when OP_2ROT
            @stack = op_2rot(@stack)
          when OP_2SWAP
            @stack = op_2swap(@stack)
          when OP_IFDUP
            @stack = op_ifdup(@stack)
          when OP_DEPTH
            @stack = op_depth(@stack)
          when OP_DROP
            @stack = op_drop(@stack)
          when OP_DUP
            @stack = op_dup(@stack)
          when OP_NIP
            @stack = op_nip(@stack)
          when OP_OVER
            @stack = op_over(@stack)
          when OP_PICK, OP_ROLL
            @stack = op_pick_or_roll(@stack, opcode)
          when OP_ROT
            @stack = op_rot(@stack)
          when OP_SWAP
            @stack = op_swap(@stack)
          when OP_TUCK
            @stack = op_tuck(@stack)
          when OP_SIZE
            @stack = op_size(@stack)
          when OP_RETURN
            @transaction_valid = op_return
          when OP_EQUAL
            @stack = op_equal(@stack)
          when OP_1ADD, OP_1SUB, OP_NEGATE, OP_ABS, OP_NOT, OP_0NOTEQUAL
            @stack = single_stack_arithmetic(@stack)
          when OP_ADD, OP_SUB, OP_BOOLAND, OP_BOOLOR, OP_NUMEQUAL, OP_NUMEQUALVERIFY, OP_NUMNOTEQUAL, OP_LESSTHAN, OP_GREATERTHAN, OP_LESSTHANOREQUAL, OP_GREATERTHANOREQUAL, OP_MIN, OP_MAX
            @stack = double_stack_arithmetic(@stack)
          when OP_WITHIN
            @stack = op_within(@stack)
          when OP_RIPEMD160, OP_SHA256, OP_SHA1, OP_HASH160, OP_HASH256
            @stack = digest(@stack)
          when OP_CHECKSIG
            raise ArgumentError, "Transaction and input are not set" if !@transaction
            op_checksig(@stack, @script, @code_separator, @transaction)
          when OP_CHECKSIGVERIFY
            raise ArgumentError, "Transaction and input are not set" if !@transaction
            @stack = op_checksig(@stack, @script, @code_separator, @transaction)
            @stack = op_verify(@stack)
          when OP_CHECKMULTISIG
            raise ArgumentError, "Transaction and input are not set" if !@transaction
            @stack = check_multisig(@stack, @script, code_separator, @transaction, opcode_count)
          when OP_CHECKMULTISIGVERIFY
            raise ArgumentError, "Transaction and input are not set" if !@transaction
            @stack = check_multisig(@stack, @script, code_separator, @transaction, opcode_count)
            @stack = op_verify(@stack)
          end
        end
      end

      # if top of stack is truthy, true
      # else, false
      if @stack.last != 0 && !@stack.empty?
        @valid = true
      else
        @valid = false
      end
    end

    def valid?
      @valid
    end
    
    def transaction_valid?
      @transaction_valid
    end
  end
end
