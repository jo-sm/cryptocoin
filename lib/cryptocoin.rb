require "cryptocoin/version"
require 'digest/sha2'

module Cryptocoin

  # Return the SHA256 hash of a string twice
  def self.double_sha256_hash(str)
    Digest::SHA256.digest(Digest::SHA256.digest([str].pack('H*').reverse)).reverse.unpack('H*')[0]
  end

  # Generate a Bitcoin style Merkle root of a set of values in an array
  def self.generate_merkle_root(arr)
    return arr[0] if arr.length == 1
    arr.push(arr.last) if arr.length % 2 == 1
    new_arr = arr.each_slice(2).map { |a, b|
      double_sha256_hash(b+a)
    }
    return self(new_arr)
  end
end
