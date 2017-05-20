# Version
require 'cryptocoin/version'

# Core extensions
require 'cryptocoin/core_ext/integer'
require 'cryptocoin/core_ext/string'

# Non cryptocoin files
require 'digest/sha2'
require 'digest/rmd160'

# General cryptocoin files
require 'cryptocoin/digest'
require 'cryptocoin/merkle_tree'
require 'cryptocoin/network'
require 'cryptocoin/protocol'
require 'cryptocoin/script'
require 'cryptocoin/structure/address'
require 'cryptocoin/structure/block'
require 'cryptocoin/structure/key_pair'
require 'cryptocoin/structure/transaction'
require 'cryptocoin/structure/merkle_branch'

# Networks
require 'cryptocoin/network/bitcoin'
require 'cryptocoin/network/litecoin'
require 'cryptocoin/network/dogecoin'

module Cryptocoin; end
