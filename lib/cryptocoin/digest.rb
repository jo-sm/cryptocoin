require 'digest/sha2'
require 'digest/rmd160'

module Cryptocoin
  class Digest
    def initialize(str)
      @plaintext = str
    end

    def to_sha256
      Digest::SHA256.hexdigest([@plaintext].pack('H*'))
    end

    def to_double_sha256
      Digest::SHA256.digest(Digest::SHA256.digest([@plaintext].pack('H*').reverse)).reverse.unpack('H*')[0]
    end

    def to_hash160
      Digest::RMD160.hexdigest(Digest::SHA256.digest([@plaintext].pack('H*')))
    end

    def to_base58
      alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
      leading_zero_bytes  = (@plaintext.match(/^([0]+)/) ? $1 : '').size / 2
      encoded = ''
      i = @plaintext.to_i(16)

      while i > 0
        i, rem = i.divmod(alphabet.size)
        encoded = alphabet[rem] + encoded
      end

      ('1'*leading_zero_bytes) + encoded
    end
  end
end
