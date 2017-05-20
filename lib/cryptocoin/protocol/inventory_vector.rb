module Cryptocoin
  module Protocol
    class InventoryVector
	  def self.parse_from_raw(raw)
	    type = raw[0..3]
      digest = raw[4..-1]
      self.new(type, digest)
	  end
	  
	  def initialize(type, digest)
	    @type_raw = type
      @digest_raw = digest
	  end
	  
	  def type
	  	@type_raw.unpack('L')[0]
	  end
	  
	  def digest
	  	@digest_raw.unpack('H*')[0]
	  end
	  
	  def raw
	  	@type_raw + @digest_raw
	  end
	end
  end
end