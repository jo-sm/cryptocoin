module Cryptocoin
  module Protocol
    class Message
      class Tx
        def self.parse_from_raw(payload)
          Cryptocoin::Structure::Transaction.parse_from_raw(payload)
        end
      end
    end
  end
end