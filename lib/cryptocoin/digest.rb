require 'digest/sha2'
require 'digest/rmd160'

module Cryptocoin
  class Digest
    def initialize(str, encoding)
      return false if ![:string, :binary].include?(encoding)
      @plaintext = str.to_s
      @encoding = encoding
    end

    def sha256
      if @encoding == :binary
        ::Digest::SHA256.hexdigest(@plaintext)
      elsif @encoding == :string
        ::Digest::SHA256.hexdigest([@plaintext].pack('H*'))
      end
    end

    def double_sha256
      if @encoding == :binary
        ::Digest::SHA256.hexdigest(::Digest::SHA256.digest(@plaintext))
      elsif @encoding == :string
        ::Digest::SHA256.hexdigest(::Digest::SHA256.digest([@plaintext].pack('H*')))
      end
    end

    def hash160
      if @encoding == :binary
        ::Digest::RMD160.hexdigest(::Digest::SHA256.digest(@plaintext))
      elsif @encoding == :string
        ::Digest::RMD160.hexdigest(::Digest::SHA256.digest([@plaintext].pack('H*')))
      end
    end
  end
end
