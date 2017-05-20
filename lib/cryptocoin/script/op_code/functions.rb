require 'cryptocoin/core_ext/integer'
require 'cryptocoin/core_ext/string'
require 'cryptocoin/script/op_code/constants'
require 'digest/sha2'
require 'digest/rmd160'

module Cryptocoin
  class Script
    class OpCode
      module Functions
        include Cryptocoin::Script::OpCode::Constants
        
        # One of a kind function
        # Sends back the stack, modified string, raw, seek
        def op_pushdata(stack, opcode, script, script_string, raw, seek)
          bytes = case opcode.hex
          when OP_PUSHDATA0..OP_PUSHDATA1
            opcode.raw
          when OP_PUSHDATA1
            seek+=1
            script[seek-1]
          when OP_PUSHDATA2
            seek+=2
            script[seek-2..seek]
          when OP_PUSHDATA4
            seek+=4
            script[seek-4..seek]
          end
          
          bytes = bytes.unpack('H*')[0].to_i(16)
          
          unless OP_PUSHDATA0..OP_PUSHDATA1 === opcode.hex
            raw += [bytes].pack('H*')
            script_string.push(bytes)
          end
          
          # Read the value from the bytes and see how much to read
          # return nil if invalid according to spec
          return false if bytes > 520
          j = script[seek..seek+bytes-1]
          script_string.push(j.unpack('H*')[0])
          raw += j
          stack.push(j)
          seek+=bytes
          [stack, script_string, raw, seek]
        end

        def op_numeric(stack, opcode)
          stack.push((opcode.hex - (OP_1 - 1)).to_openssl_bn)
        end

        def op_if(stack, exec_stack, opcode)
          require_stack stack do
            val = false
            i = stack.pop
            if !!i.to_openssl_bn_int
              val = true if opcode.hex == OP_IF
            else
              val = true if opcode.hex == OP_NOTIF
            end
            exec_stack.push(val)
            [stack, exec_stack]
          end
        end

        def op_else(exec_stack)
          require_stack exec_stack do
            exec_stack[-1] = !exec_stack[-1]
            exec_stack
          end
        end

        def op_endif(exec_stack)
          require_stack exec_stack do
            exec_stack.pop
            exec_stack
          end
        end

        def op_verify(stack, transaction_valid)
          require_stack stack do
            i = stack.pop
            if i.to_openssl_bn_int == 0
              stack.push(i)
              transaction_valid = false
            end
            [stack, transaction_valid]
          end
        end

        def op_toaltstack(stack, alt_stack)
          require_stack stack do
            alt_stack.push(stack.pop)
          end
          [stack, alt_stack]
        end

        def op_fromaltstack(stack, alt_stack)
          require_stack alt_stack do
            stack.push(alt_stack.pop)
          end
          [stack, alt_stack]
        end

        def op_2drop(stack)
          require_stack stack, 2 do
            2.times do
              stack.pop
            end
            stack
          end
        end

        def op_2dup(stack)
          require_stack stack, 2 do
            i = stack[-1]
            j = stack[-2]
            stack.push(i, j)
            stack
          end
        end

        def op_3dup(stack)
          require_stack stack, 3 do
            i = stack[-1]
            j = stack[-2]
            k = stack[-3]
            stack.push(i, j, k)
            stack
          end
        end

        def op_2over(stack)
          require_stack stack, 4 do
            i = stack[-3]
            j = stack[-4]
            stack.push(i, j)
            stack
          end
        end

        def op_2rot(stack)
          require_stack stack, 6 do
            i = stack.slize!(-6,2)
            stack.push(i).flatten!
            stack
          end
        end

        def op_2swap(stack)
          require_stack stack, 4 do
            i = stack.pop(2)
            j = stack.pop(2)
            stack.push(i, j)
            stack
          end
        end
        
        def op_ifdup(stack)
          require_stack stack do
            stack.push(stack.last) if stack.last != 0.to_openssl_bn_int
          end
        end

        def op_depth(stack)
          stack.push(stack.size.to_openssl_bn)
          stack
        end

        def op_nop
          # Doesn't do anything
          true 
        end

        def op_drop(stack)
          require_stack stack do
            stack.pop
            stack
          end
        end

        def op_dup(stack)
          require_stack stack do
            stack.push(stack.last)
            stack
          end
        end

        def op_nip(stack)
          require_stack stack, 2 do
            stack.slice!(-2)
            stack
          end
        end

        def op_over(stack)
          require_stack stack, 2 do
            stack.push(stack.slice(-2))
            stack
          end
        end

        def op_pick_or_roll(stack, opcode)
          require_stack stack, 2 do
            p = stack.pop
            i = stack.slice(p, 1) if opcode.hex == OP_PICK
            i = stack.slice!(p, 1) if opcode.hex == OP_ROLL
            stack.push(i)
            stack
          end
        end

        def op_rot(stack)
          require_stack stack, 3 do
            i = stack.slice!(-3,1)
            stack.push(i)
            stack
          end
        end

        def op_swap(stack)
          require_stack stack, 2 do
            i = stack.slice!(-2,1)
            stack.push(i)
            stack
          end
        end

        def op_tuck(stack)
          require_stack stack, 2 do
            stack.insert(-3, stack.last)
          end
        end
        
        # Pushes the size of the item at the top of the stack
        # Note: the stack processing is done in binary, and Ruby treats
        # binary as strings
        def op_size(stack)
          stack.push([stack.last.bytesize].pack('C*'))
          stack
        end
        
        # Reference client treats OP_RETURN as fail condition
        # for script. OP_RETURN sets the transaction as invalid
        # but otherwise the script can be valid
        def op_return
          false
        end

        def op_verify(stack, transaction_valid)
          require_stack stack do
            i = stack.pop
            if i.to_bn.to_i == 0
              stack.push(i)
              transaction_valid = false
            end
            [stack, transaction_valid]
          end
        end

        def op_equal(stack)
          require_stack stack, 2 do
            i, j = stack.pop(2)
            stack.push(i == j ? 1 : 0)
            stack
          end
        end

        def single_stack_arithmetic(stack, opcode)
          require_stack stack do
            i = stack.pop.to_openssl_bn_int
            case opcode.hex
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
            stack.push(i.to_openssl_bn)
            stack
          end
        end

        def double_stack_arithmetic(stack)
          require_stack stack, 2 do
            i, j = stack.pop.map { |e| e.to_openssl_bn_int }
            case opcode.hex
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
              op_verify if @opcode == OP_NUMEQUALVERIFY
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
            stack.push(k.to_openssl_bn)
            stack
          end
        end

        def op_within(stack)
          require_stack stack do
            i, j, k = stack.pop(3).map{|e| e.to_openssl_bn_int}
            l = (j <= i and i < k)
            stack.push(l.to_openssl_bn)
            stack
          end
        end

        def digest(stack, opcode)
          require_stack stack do
            i = stack.pop
            case opcode.hex
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
            stack.push(j)
            stack
          end
        end

        def op_codeseparator(seek)
          seek # Allow for future changes to this opcode
        end

        # One of the two opcodes that requires outside knowledge from
        # the stack itself, since the transaction information isn't
        # directly part of the script
        def op_checksig(stack, script, code_separator, transaction)
          pubkey = stack.pop
          sig = stack.pop
          
          hash_type = sig[-1].unpack('C')[0]
          signature = sig[0..-2]
          
          if is_canonical_pubkey?(pubkey) and is_canonical_signature?(signature)
            stack = check_sig(signature, hash_type, pubkey, script, code_separator, transaction)
            return stack.push(0.to_openssl_bn) if !stack
            stack.push(1.to_openssl_bn)
          else
            stack.push(0.to_openssl_bn)
          end
          stack
        end

        def op_multisig(stack, script, code_separator, transaction, opcode_count)
          require_stack do
            i = stack.pop.to_openssl_bn_int
            return false if !i.between?(1,19) #inclusive
            opcode_count += i
            return false if opcode_count > 201
            return false if stack.size < i+1
            j = stack.size
            while stack.size > j-i
              stack = op_checksig(stack, script, code_separator, transaction)
              return stack.push(0.to_openssl_bn) if !stack
            end
            stack.push(1.to_openssl_bn)
          end
        end

        private

        def check_sig(signature, hash_type, pubkey, script, code_separator, transaction)          
          # get the script from codeseparator to end as subscript
          # remove codeseparator from resulting script
          # remove signature from script
          subscript = Cryptocoin::Script.new(script[code_separator..-1])
          subscript.is_subscript! # calls for removal of op_separate and signature
          
          tx_copy = transaction.copy # in case we need to reset tx_copy
          tx_copy.inputs.each do |i|
            if i.index == @input_index
              i.script_sig_length = Cryptocoin::Protocol::VarLenInt.from_int(subscript.raw.bytesize)
              i.script_sig = subscript.raw
            else
              i.script_sig_length = 0.to_openssl_bn
              i.script_sig = 0.to_openssl_bn
            end
          end
          case hash_type
          when 2
            # SIGHASH_NONE
            tx_copy.out_length = Cryptocoin::Protocol::VarLenInt.from_int(0)
            tx_copy.outputs = ''
            tx_copy.inputs.each do |i|
              i.sequence = [0].pack('V') unless i == @input_index
            end
          when 3
            # SIGHASH_SINGLE
            if input_index >= tx_copy.outputs.length
              # Special case, see https://github.com/bitcoinj/bitcoinj/blob/4df728a7d9210dc9ac5a5ae5188c89f5e9d41852/core/src/main/java/com/google/bitcoin/core/Transaction.java#L1018
              # We're essentially resetting the transaction due to a bug
              tx_copy = transaction
              hash = Digest::SHA256([0100000000000000000000000000000000000000000000000000000000000000].pack('C*'))
              bug = true
            else
              n_o = []
              tx_copy.outputs.each do |o|
                if o.index == @input_index
                  n_o.push(i)
                elsif o.index < @input_index
                  # TODO: Implement this in a transaction builder
                  n_o.push(Cryptocoin::Structure::Transaction::Output.new(0, [-1].pack('q') + Cryptocoin::Protocol::VarLenInt.from_int(0)))
                end
              end
              tx_copy.outputs = n_o
              tx_copy.inputs.each do |i|
                i.sequence = 0.to_openssl_bn_int
              end
            end
          when 80
            # SIGHASH_ANYONECANPAY
            n_i = []
            tx_copy.inputs.each do |i|
              n_i.push(i) if i.index == @input.index
            end
          end
          if !bug
            # Do this if there's a bug in the reference client *SIGHASH_SINGLE*
            i = tx_copy.raw + [hash_type].pack('V')
            hash = Digest::SHA256.digest(Digest::SHA256.digest(i))
          end
          begin
            k = OpenSSL::PKey::EC.new("secp256k1")
            k.public_key = OpenSSL::PKey::EC::Point.new(k.group, OpenSSL::BN.new(pubkey.unpack('H*')[0], 16))
            if k.dsa_verify_asn1(hash, signature)
              stack.push(1.to_openssl_bn)
            else
              stack.push(0.to_openssl_bn)
            end
          rescue OpenSSL::PKey::ECError, OpenSSL::PKey::EC::Point::Error
            stack.push(0.to_openssl_bn)
          end
          stack
        end

        def is_canonical_signature?(sig)
          return false if sig.bytesize < 9
          return false if sig.bytesize > 73
          return false if !["\x01", "\x02", "\x03", "\x80"].include?(sig[-1])
          return false if sig[0] != "\x30"
          return false if sig[1].to_bn_to_i != sig.bytesize-3
          r_length = sig[3].to_bn.to_i
          return false if 5 + r_length >= sig.bytesize
          s_length = sig[5+r_length]
          return false if r_length + s_length + 7 != sig.bytesize
          r = sig[4, r_length]
          return false if r[-2] != "\x02"
          return false if r.bytesize == 0
          return false if r.bytes.inject{|x,y| (x<<8) | y} & 0x80
          return false if r.bytesize > 1 and (r[0] == "\x00" and !(r[1].getbyte(0) & 0x80))
          true
        end

        def is_canonical_pubkey?(pubkey)
          return false if pubkey.bytesize < 33 
          case pubkey[0]
          when "\x04"
            # uncompressed pubkey
            return false if pubkey.bytesize != 65
          when "\x02", "\x03"
            # compressed pubkey
            return false if pubkey.bytesize != 33
          else
            # invalid first byte
            return false
          end
          true
        end

        def require_stack(stack, size=1, &block)
          if stack.size >= size
            yield
          else
            nil
          end
        end
      end
    end
  end
end
