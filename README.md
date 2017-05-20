# Cryptocoin

Cryptocoin is a library for processing information from a Bitcoin-based cryptocoin network and wrapping that data in a useful and Ruby-like manner. Although based off of `bitcoin-ruby` in concept, it deviates largely due to its philosophy in implementations; rather than trying to do everything, `cryptocoin` just provides wrappers around cryptocoin structures such as a block or merkle tree. Due to this difference, it cannot do certain features such as block validation, as block validation requires information beyond the basic structure (multiple transactions). 

## Installation

Add this line to your application's Gemfile:

    gem 'cryptocoin'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cryptocoin

## Notes

### Usage Notes

Since Ruby uses the method `hash` as an internal descriptor for objects, in general, the result of a hashing function such as `RIPEMD160` or `SHA256` will be referred to as a digest.

### Library Notes

Cryptocoin will only work with cryptocurrencies that follow the Bitcoin protocol.

This library does not perform validation of blocks or transactions; it only acts as a data parser. The reason for this is that validation is inherently coupled with a storage solution, such as an SQL database, for certain validation rules and the purpose of this library is only to parse data. For a library that performs validation, see `cryptocoin-validator`.

For importing from a blockchain data file, see `cryptocoin-import`.

## Sample Usage

### Generate a new key pair

```
require 'cryptocoin'
key_pair = Cryptocoin::Structure::KeyPair.generate
public_address = key_pair.public_key.to_address.to_s
private_address = key_pair.private_key.to_address.to_s
```

(Note: The reason `to_s` is called is that `to_address` creates a new `Cryptocoin::Structure::Address` instance which can then be turned into a string via `to_s`.)

### Create a new Script

```
require 'cryptocoin'
script = Cryptocoin::Script.from_s("OP_1")
script.parse! #=> true
```

## What's built with `cryptocoin`?

Officially supported (coming soon!):
* `cryptocoin-validator`: a block and transaction validator based off of Bitcoin protocol validation rules. Works with SHA256 (Bitcoin) and Scrypt (Litecoin) based currencies
* `cryptocoin-import`: a blockchain data file importer. Reads a blockchain file, i.e. `blk00001.dat`, and imports it into the database. 

## Thanks

A lot of this code couldn't be possible without `bitcoin-ruby`, the library that started this idea. Also a huge help were the [Bitcoin wiki](https://www.bitcoin.it) and the current Bitcoin source code v0.9. A special thanks to the `bitcoinj` library for its Script directive processing, especially for OP_CHECKSIG.

## Contributing

### What's missing?

* Support for BIP 0037, titled, "Connection Bloom Filtering"
* Support for other cryptocurrencies besides Litecoin, Bitcoin, and Dogecoin

### How to Contribute

If you find a bug or would like to add a new feature, fork the library and create a PR based on your changes! Keep the code consistent with my existing code, and follow similar conventions to the existing ones.

When creating a PR that adds a new feature, make sure you justify its utility to the base library, with some use cases in the PR or in a gist. Ideally the library will be kept as slim as possible, and additonal non-essential functionality for data parsing will be added to other libraries.

One area I would really like help with is adding various networks to the library, as I only included a handful (Bitcoin, Litecoin, Dogecoin). If you're knowledgeable with a different cryptocoin and want to add it to the library, fork, create, and request to pull it! I'd love to have more than just three!

#### Instructions for forking

1. Fork it ( https://github.com/joshuasmock/cryptocoin/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
