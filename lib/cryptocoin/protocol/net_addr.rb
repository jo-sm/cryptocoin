module Cryptocoin
  module Protocol
    class NetAddr
      def self.parse_from_raw(raw)
        timestamp = raw[0..3]
        services = raw[4..11]
        address = raw[12..27]
        port = raw[28..29]
        self.new(timestamp, services, address, port)
      end
      
      def initialize(timestamp, services, address, port)
        @timestamp_raw = timestamp
        @services_raw = services
        @address_raw = address
        @port_raw = port
      end
      
      def timestamp
        @timestamp ||= @timestamp_raw.unpack('L')[0]
      end
      
      def services
        @services ||= @services_raw.unpack('Q')[0]
      end
      
      def address
        return @address if @address
        address = @address_raw.unpack('H*')[0]
        if address[0..11] == "000000000000" # IPv4 address
          address = address[12..-1]
          @address = address.each_char.each_slice(2).map{|e| e.join.to_i(16)}.join('.')
          @address_version = 4
        else
          @address = address.each_char.each_slice(4).map{|e| e.join}.join(':')
          @address_version = 6
        end
        @address
      end
      
      def port
        @port ||= @port_raw.unpack('S')[0]
      end
      
      def address_with_port
        return "#{@address}:#{@port}" if @address_version == 4
        "[#{@address}]:#{@port}"
      end
      
      def raw
        @timestamp_raw + @services_raw + @address_raw + @port_raw
      end
	  end
  end
end