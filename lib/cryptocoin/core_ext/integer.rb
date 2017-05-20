class Integer
  def to_bool
    !self.zero?
  end

  def to_openssl_bn
    require 'openssl'
    s = OpenSSL::BN.new(self.to_s).to_s(0)
    s = s[s.length-1..-1]
    s
  end
  
  def to_base58
    alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
    encoded = ''
    i = self

    while i > 0
      i, rem = i.divmod(58)
      encoded = alphabet[rem] + encoded
    end
    encoded
  end
end
