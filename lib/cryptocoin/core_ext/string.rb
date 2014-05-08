class String
  def to_openssl_bn_int
    OpenSSL::BN.new([self.bytesize].pack('N') + self.reverse, 0).to_i
  end
end
