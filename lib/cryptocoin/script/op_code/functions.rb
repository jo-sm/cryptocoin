require 'cryptocoin/core_ext/fixnum'
require 'cryptocoin/core_ext/string'
require 'cryptocoin/script/op_code/constants'
require 'digest/sha2'
require 'digest/rmd160'

module Cryptocoin
  class Script
    module OpCode
      module Functions
        include Constants

        def op_pushdata
          bytes = case @_i.hex
          when OP_PUSHDATA0
            @_i
          when OP_PUSHDATA1
            @directive.read
          when OP_PUSHDATA2
            @directive.read(2)
          when OP_PUSHDATA4
            @directive.read(4)
          end

          bytes = bytes.unpack('H*')[0].to_i(16)
          # Read the value from the bytes and see how much to read
          # return nil if invalid according to spec
          return nil if bytes > 520
          @stack.push(@directive.read(bytes))
        end

        def op_numeric
          case @_i.hex
          when OP_1NEGATE
            @stack.push(-1.to_openssl_bn)
          else
            @stack.push(@_i.hex - (OP_1 - 1).to_openssl_bn)
          end
        end

        def op_if
          require_stack do
            val = false
            i = @stack.pop
            if i.to_bool
              val = true if @_i.hex == OP_IF
            else
              val = true if @_i.hex == OP_NOTIF
            end
            @exec_stack.push(val)
          end
        end

        def op_else
          return nil if @exec_stack.empty?
          @exec_stack[-1] = !@exec_stack[-1]
        end

        def op_endif
          return nil if @exec_stack.empty?
          @exec_stack.pop
        end

        def op_verify
          require_stack do
            i = @stack.pop
            if !i.to_bool
              @stack.push(i)
              @transaction_invalid = true
            end
          end
        end

        def op_toaltstack
          require_stack do
            @alt_stack.push(@stack.pop)
          end
        end

        def op_fromaltstack
          require_alt_stack do
            @stack.push(@alt_stack.pop)
          end
        end

        def op_2drop
          require_stack(2) do
            2.times do
              @stack.pop
            end
          end
        end

        def op_2dup
          require_stack(2) do
            i = @stack[-1]
            j = @stack[-2]
            @stack.push(i, j)
          end
        end

        def op_3dup
          require_stack(3) do
            i = @stack[-1]
            j = @stack[-2]
            k = @stack[-3]
            @stack.push(i, j, k)
          end
        end

        def op_2over
          require_stack(4) do
            i = @stack[-3]
            j = @stack[-4]
            @stack.push(i, j)
          end
        end

        def op_2rot
          require_stack(6) do
            i = @stack.slize!(-6,2)
            @stack.push(i).flatten!
          end
        end

        def op_2swap
          require_stack(4) do
            i = @stack.pop(2)
            j = @stack.pop(2)
            @stack.push(i, j)
          end
        end
        
        def op_ifdup
          require_stack do
            @stack.push(@stack.last) if @stack.last !== 0.to_openssl_bn
          end
        end

        def op_depth
          @stack.push(@stack.size)
        end

        def op_drop
          require_stack do
            @stack.pop
          end
        end

        def op_dup
          require_stack do
            @stack.push(@stack.last)
          end
        end

        def op_nip
          require_stack(2) do
            @stack.slice!(-2)
          end
        end

        def op_over
          require_stack(2) do
            @stack.push(@stack.slice(-2))
          end
        end

        def op_pick_or_roll
          require_stack(2) do
            p = @stack.pop
            i = @stack.slice(p, 1) if @_i.hex == OP_PICK
            i = @stack.slice!(p, 1) if @_i.hex == OP_ROLL
            @stack.push(i)
          end
        end

        def op_rot
          require_stack(3) do
            i = @stack.slice!(-3,1)
            @stack.push(i)
          end
        end

        def op_swap
          require_stack(2) do
            i = @stack.slice!(-2,1)
            @stack.push(i)
          end
        end

        def op_tuck
          require_stack(2) do
            @stack.insert(-3, @stack.last)
          end
        end
        
        # Pushes the size of the item at the top of the stack
        # Note: the stack processing is done in binary, and Ruby treats
        # binary as strings
        def op_size
          @stack.push(@stack.last.bytesize)
        end

        # Current implementation treats OP_RETURN
        # as being false as the same as other fail
        # conditions. This implementation treats
        # the transaction as invalid but leaves the 
        # script as being valid
        def op_return
          @transaction_invalid = true
          true
        end

        def op_verify
          require_stack do
            i = @stack.pop
            if i == 0.to_openssl_bn
              @stack.push(i)
              @transaction_valid = false
            end
          end
        end

        def op_equal
          require_stack(2) do
            i, j = @stack.pop(2)
            @stack.push(i == j ? 1 : 0)
            op_verify if @_i.hex == OP_EQUALVERIFY
          end
        end

        def single_stack_arithmetic
          require_stack do
            i = @stack.pop.to_openssl_bn_int
            case @_i.hex
            when OP_1ADD
              i += 1
            when OP_1SUB
              i -= 1
            when OP_NEGATE
              i = -i
            when OP_ABS
              i = i.abs
            when OP_NOT
              i = (i == 0)
            when OP_0NOTEQUAL
              i = (i != 0)
            end
            @stack.push(i.to_openssl_bn)
          end
        end

        def double_stack_arithmetic
          require_stack(2) do
            i, j = @stack.pop.map { |e| e.to_openssl_bn_int }
            case @_i.hex
            when OP_ADD
              k = i + j
            when OP_SUB
              k = i - j
            when OP_BOOLAND
              k = (i != 0 and j != 0)
            when OP_BOOLOR
              k = (i != 0 or j != 0)
            when OP_NUMEQUAL, OP_NUMEQUALVERIFY
              k = (i == j)
              op_verify if @_i == OP_NUMEQUALVERIFY
            when OP_NUMNOTEQUAL
              k = (i != j)
            when OP_LESSTHAN
              k = (i < j)
            when OP_GREATERTHAN
              k = (i > j)
            when OP_LESSTHANOREQUAL
              k = (i <= j)
            when OP_GREATERTHANOREQUAL
              k = (i >= j)
            when OP_MIN
              k = (i < j ? i : j)
            when OP_MAX
              k = (i < j ? j : i)
            end
            @stack.push(i.to_openssl_bn)
          end
        end

        def op_within
          require_stack(3) do
            i, j, k = @stack.pop(3)
            l = (j <= i and i < k)
            @stack.push(l)
          end
        end

        def digest
          require_stack do
            i = @stack.pop
            case @_i.hex
            when OP_RIPEMD160
              j = Digest::RMD160.digest(i)
            when OP_SHA256
              j = Digest::SHA256.digest(i)
            when OP_SHA1
              j = Digest::SHA1.digest(i)
            when OP_HASH160
              j = Digest::RMD160.digest(Digest::SHA256.digest(i))
            when OP_HASH256
              j = Digest::SHA256.digest(Digest::SHA256.digest(i))
            end
            @stack.push(j)
          end
        end

        def op_codeseparator
          @separator = @directive.pos
        end

        # One of the two opcodes that requires outside knowledge from
        # the script itself, since the transaction information isn't
        # directly part of the script
        def op_checksig(transaction)
          pubkey = @stack.pop
          signature = @stack.pop
          hash_type = signature[-1].unpack('C')[0]
          signature = signature[0..-2]
          
          # get the script from codeseparator to end as subscript
          # remove codeseparator from resulting script
          # remove signature from script
          pos = @directive.pos
          subscript = Cryptocoin::Script.new(@directive.seek(@separator).read, true)
          @directive.seek(pos)
          
          tx_copy = transaction

        end

        private

        def require_stack(size=1, &block)
          if @stack.size >= size
            yield
          else
            nil
          end
        end

        def require_alt_stack(size=1, &block)
          if @alt_stack.size >= size
            yield
          else
            nil
          end
        end

        def require_exec_stack(size=1, &block)
          if @exec_stack.size >= size
            yield
          else
            nil
          end
        end
      end
    end
  end
