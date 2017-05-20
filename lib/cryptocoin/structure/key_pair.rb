require 'cryptocoin/core_ext/string'
require 'cryptocoin/core_ext/integer'
require 'cryptocoin/structure/address'

module Cryptocoin
  module Structure
    class KeyPair
      attr_reader :network, :public_key, :private_key
      
      def self.generate(network)
        key = OpenSSL::PKey::EC.new("secp256k1").generate_key
        new(key, network)
      end
      
      def initialize(key_pair, network)
        @network = network
        
        @public_key = PublicKey.new(key_pair.public_key, network)
        @private_key = PrivateKey.new(key_pair.private_key, network)
      end
      
      class PublicKey
        def initialize(public_key, network)
          @network = network
          @public_key = public_key
        end
        
        def to_s
          @public_key.to_bn.to_i.to_s(16)
        end
        
        def to_address
          kh = @network.hash160_version + Cryptocoin::Digest.new(to_s, :string).hash160
          checksum = Cryptocoin::Digest.new([kh].pack('H*'), :binary).double_sha256[0..7]
          Cryptocoin::Structure::Address.from_s((kh + checksum).encode_to_base58, @network)
        end
      end
      
      class PrivateKey
        def initialize(private_key, network)
          @network = network
          @private_key = private_key
        end
        
        def to_s
          @private_key.to_bn.to_i.to_s(16)
        end
        
        def to_address 
          kh =  @network.private_key_version + Cryptocoin::Digest.new(to_s, :string).double_sha256
          checksum = Cryptocoin::Digest.new([kh].pack('H*'), :binary).double_sha256[0..7]
          Cryptocoin::Structure::Address.from_s((kh + checksum).to_i(16).to_base58, @network)
        end
      end
    end
  end
end