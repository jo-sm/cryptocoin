module Cryptocoin
  class Network
    Bitcoin = self.new
    Bitcoin.magic_head_raw = "\xF9\xBE\xB4\xD9"
    Bitcoin.hash160_version_raw = "\x00"
    Bitcoin.p2sh_version_raw = "\x05"
    Bitcoin.private_key_version_raw = "\x80"
  end
end