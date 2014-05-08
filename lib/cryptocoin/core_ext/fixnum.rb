class Fixnum
  def to_bool
    !self.zero?
  end

  def to_openssl_bn
    require 'openssl'
    s = OpenSSL::BN.new(self.to_s).to_s(0)
    s = s[s.length-1..-1]
    s
  end
end
