require 'cryptocoin/core_ext/string'

module Cryptocoin
  module Structure
    # An address is just a specific way to represent a series of bytes within the network
    class Address
      attr_reader :network
      # Creates a new Address structure from a given hash and network
      # Will return false if the address is just 1 as this the representation of 0
      def self.from_s(address_hash, network)
        s = address_hash.from_base58.to_s(16)
        '0'+s = s if s.bytesize.odd?
        return false if s == '00'
        
        i = (address_hash.match(/^([1]+)/) ? $1 : '').size
        self.new(['00'*i + s].pack('H*'), network)
      end
         
      def initialize(address, network)
        @address_raw = address
        @network = network
      end
      
      # Returns identifier for address type
      # Current address types are p2sh and hash160
      def type
        return :p2sh if digest[0..1] == network.p2sh_version
        return :hash160 if digest[0..1] == network.hash160_version
        return :private_key if digest[0..1] == network.private_key_version
        :unknown
      end
      
      def to_s
        digest.encode_to_base58
      end
      
      def checksum
        digest[-8..-1]
      end
      
      def digest
        @address_raw.unpack('H*')[0]
      end
      
      def valid?
        valid_checksum? and valid_network_version?
      end
      
      private
      
      def valid_checksum?
        if type == :private_key
          Cryptocoin::Digest.new([digest[0..-9]].pack('H*'), :binary).double_sha256[0..7] == checksum
        else
          Cryptocoin::Digest.new([digest[0..-9]].pack('H*'), :binary).double_sha256[0..7] == checksum
        end
      end
      
      def valid_network_version?
        type != :unknown
      end
    end
  end
end