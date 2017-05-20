module Cryptocoin
  class Network
    Litecoin = self.new
    Litecoin.magic_head_raw = "\xfb\xc0\xb6\xdb"
    Litecoin.hash160_version_raw = "\x30"
    Litecoin.p2sh_version_raw = "\x05"
    Litecoin.private_key_version_raw = "\xb0"
  end
end