require 'cryptocoin/protocol/var_len_int'

module Cryptocoin
  module Structure
    class Transaction
      class Input
        attr_reader :index, :previous_output_hash, :previous_output_index, :script_sig_length, :script_sig, :sequence
        
        # Parses a raw binary transaction input
        # Takes a raw transaction input and outputs a
        # Crytocoin::Structure::Transaction::Input object
        def self.parse_from_raw(i, raw)
          c = 0
          previous_output_hash_raw = raw[c..32]
          previous_output_index_raw = raw[c+32..36]
          sequence = raw[-5..-1]
          c += 36
          script_sig_length = Cryptocoin::Protocol::VarLenInt.parse_from_raw(raw[c..-1])
          script_sig = raw[c+script_sig_length..-5]
          self.new(previous_output_hash_raw, previous_output_index_raw, script_sig_length, script_sig, sequence, i)
        end
        
        # Parses the top transaction input from io
        # Returns a Cryptocoin::Structure::Transaction::Input object
        def self.parse_from_io(i, io)
          previous_output_hash_raw = io.read(32)
          previous_output_index_raw = io.read(4)
          script_sig_length = Cryptocoin::Protocol::VarLenInt.parse_from_io(io)
          script_sig = io.read(script_sig_length.to_i)
          sequence_raw = io.read(4)
          self.new(previous_output_hash_raw, previous_output_index_raw, script_sig_length, script_sig, sequence_raw, i)
        end
        
        # Creates a new transaction input from supplied arguments, then freezes itself
        # Types: (str) previous_output_hash, (str) previous_output_index
        # (Cryptocoin::Protocol::VarLenInt) sig_script_length, (str) script_sig
        # (str) sequence, (int) index
        def initialize(previous_output_hash, previous_output_index, script_sig_length, script_sig_raw, sequence, index)
          @previous_output_hash_raw = previous_output_hash
          @previous_output_index_raw = previous_output_index
          @script_sig_length = script_sig_length
          @script_sig_raw = script_sig_raw
          @sequence_raw = sequence
          @index = index
        end
        
        def previous_output_hash
          @previous_output_hash_raw.reverse.unpack('H*')[0]
        end
        
        def previous_output_index
          @previous_output_index_raw.unpack('V')[0]
        end
        
        def script_sig
          @script_sig ||= Cryptocoin::Script.new(@script_sig_raw)
        end

        def raw
          @previous_output_hash_raw + @previous_output_index_raw + @script_sig_length.raw + @script_sig + @sequence
        end
        
        def size
          raw.bytesize
        end
        
        # Provides a copy of the transaction in which you can set the raw binary values
        def copy
          r = self
          ['previous_output_hash_raw', 'previous_output_index_raw', 'script_sig_length', 'script_sig', 'sequence_raw'].each do |i|
            r.class.send(:define_method, "#{i}=") do |j|
              instance_variable_set("@#{i}", j)
            end
          end
          r
        end
      end
    end
  end
end