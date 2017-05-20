module Cryptocoin
  class Network
    Dogecoin = self.new
    Dogecoin.magic_head_raw = "\xc0\xc0\xc0\xc0"
    Dogecoin.hash160_version_raw = "\x1e"
    Dogecoin.p2sh_version_raw = "\x22"
    Dogecoin.private_key_version_raw = "\x9e"
  end
end