require 'cryptocoin/core_ext/integer'

class String
  def to_openssl_bn_int
    require 'openssl'
    OpenSSL::BN.new([self.bytesize].pack('N') + self.reverse, 0).to_i
  end
  
  # Returns the integer value from a base58 encoded string
  def from_base58
    return nil if self.match(/[0OIl]/)
    alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
    j = 0
        
    self.reverse.each_char.with_index do |c, i|
      j += alphabet.index(c) * (58**i)
    end
    j
  end
  
  def reverse_every(n)
    self.each_char.each_slice(n).reverse_each.reduce(''){|r,i| r+=i.join}
  end
  
  def encode_to_base58
    return nil if self.to_i(16) == 0
    i = (self.match(/^([0]+)/) ? $1 : '').size / 2
    ('1'*i) + self.to_i(16).to_base58
  end
end
