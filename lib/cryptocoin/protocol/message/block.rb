require 'cryptocoin/structure/block'

module Cryptocoin
  module Protocol
    class Message
      class Block
        def initialize(payload)
          Cryptocoin::Structure::Block.parse_from_raw(payload)
        end
      end
    end
  end
end