require 'cryptocoin/structure/transaction/input'
require 'cryptocoin/structure/transaction/output'
require 'cryptocoin/protocol/var_len_int'

module Cryptocoin
  module Structure
    class Transaction
      attr_reader :inputs, :outputs
      
      def self.parse_from_io(io)
        inputs, outputs = [], []
        version_raw = io.read(4)
        in_length = Cryptocoin::Protocol::VarLenInt.parse_from_io(io)
        in_length.times do |i|
          inputs.push(Cryptocoin::Structure::Transaction::Input.parse_from_io(i, io))
        end
        out_length = Cryptocoin::Protocol::VarLenInt.parse_from_io(io)
        out_length.times do |i|
          outputs.push(Cryptocoin::Structure::Transaction::Output.parse_from_io(i, io))
        end
        lock_time_raw = io.read(4)
        self.new(version_raw, in_length, inputs, out_length, outputs, lock_time_raw)
      end
      
      def self.parse_from_raw(raw)
        c = 0
        inputs, outputs = [], []
        version_raw = raw[c..5]
        c += 5
        in_length = Cryptocoin::Protocol::VarLenInt.new(raw[c..-1]) # Don't know the length
        c += in_length.raw.bytesize
        in_length.times do |i|
          tx = Cryptocoin::Structure::Transaction::Input.parse_from_raw(i, raw[c..-1])
          inputs.push(tx)
          c += tx.raw.bytesize
        end

        out_length = Cryptocoin::Protocol::VarLenInt.new(raw[c..-1])
        out_length.times do |i|
          tx = Cryptocoin::Structure::Transaction::Output.parse_from_raw(i, raw[c..-1])
          outputs.push(tx)
          c += tx.raw.bytesize
        end
        lock_time_raw = raw[c..c+4]
        self.new(version_raw, in_length, inputs, out_length, outputs, lock_time_raw)
      end
      
      def initialize(version_raw, in_length, inputs, out_length, outputs, lock_time_raw)
        @version_raw = version_raw
        @in_length = in_length
        @inputs = inputs
        @out_length = out_length
        @outputs = outputs
        @lock_time_raw = lock_time_raw
      end
      
      def version
        @version_raw.unpack('V')[0]
      end
      
      def lock_time
        @lock_time_raw.unpack('V')[0]
      end

      def raw
        @version_raw + @in_length.raw + @inputs.map{|e| e.raw }.join + @out_length.raw + @outputs.map{|e| e.raw}.join + @lock_time_raw
      end
      
      def size
        raw.bytesize
      end
      
      def copy
        r = self
        ['lock_time_raw', 'version_raw', 'inputs', 'outputs'].each do |i|
          r.class.send(:define_method, "#{i}=") do |j|
            instance_variable_set("@#{i}", j)
          end
        end
        a = []
        r.inputs.each do |i|
          a.push(i.copy)
        end
        r.inputs = a
        a = []
        r.outputs.each do |i|
          a.push(i.copy)
        end
        r.outputs = a
        r
      end
    end
  end
end
