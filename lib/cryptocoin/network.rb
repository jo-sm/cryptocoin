module Cryptocoin
  # Class contains protocol information like the magic_head and address types
  # Does NOT contain validation information as this would require dependence on an outside source
  # of information
  class Network
    attr_accessor :magic_head_raw, :hash160_version_raw, :p2sh_version_raw, :private_key_version_raw, :protocol_version_raw
    
    def magic_head
      @magic_head ||= @magic_head_raw.unpack('H*')[0]
    end
    
    def magic_head=(magic_head)
      @magic_head_raw = [magic_head].pack('H*')
      @magic_head = nil
    end
    
    def hash160_version
      @hash160_version ||= @hash160_version_raw.unpack('H*')[0]
    end
    
    def hash160_version=(hash160_version)
      @hash160_version_raw = [hash160_version].pack('H*')
      @hash160_version = nil
    end
    
    def p2sh_version
      @p2sh_version ||= @p2sh_version_raw.unpack('H*')[0]
    end
    
    def p2sh_version=(p2sh_version)
      @p2sh_version_raw = [p2sh_version].pack('H*')
      @p2sh_version = nil
    end
    
    def private_key_version
      @private_key_version_raw.unpack('H*')[0]
    end
    
    def private_key_version=(private_key_version)
      @private_key_version_raw = [private_key_version].pack('H*')
      @private_key_version = nil
    end
    
    def protocol_version
      @protocol_version ||= @protocol_version_raw.unpack('H*')[0]
    end
    
    def protocol_version=(protocol_version)
      @protocol_version_raw = [protocol_version].pack('H*')
      @protocol_version = nil
    end
  end
end