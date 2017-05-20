require 'cryptocoin/protocol/message/addr'
require 'cryptocoin/protocol/message/alert'
require 'cryptocoin/protocol/message/block'
require 'cryptocoin/protocol/message/getaddr'
require 'cryptocoin/protocol/message/getblocks'
require 'cryptocoin/protocol/message/getdata'
require 'cryptocoin/protocol/message/getheaders'
require 'cryptocoin/protocol/message/headers'
require 'cryptocoin/protocol/message/inv'
require 'cryptocoin/protocol/message/mempool'
require 'cryptocoin/protocol/message/notfound'
require 'cryptocoin/protocol/message/ping'
require 'cryptocoin/protocol/message/pong'
require 'cryptocoin/protocol/message/reject'
require 'cryptocoin/protocol/message/tx'
require 'cryptocoin/protocol/message/verack'
require 'cryptocoin/protocol/message/version'

module Cryptocoin
  module Protocol
    class Message
      def self.parse(command, payload)
        Cryptocoin::Protocol::Message.const_get(command.capitalize).parse_from_raw(payload)
      end
    end
  end
end
