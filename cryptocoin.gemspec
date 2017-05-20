# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cryptocoin/version'

Gem::Specification.new do |spec|
  spec.name          = "cryptocoin"
  spec.version       = Cryptocoin::VERSION
  spec.authors       = ["Joshua Smock"]
  spec.email         = ["joshua.smock@gmail.com"]
  spec.summary       = %q{Cryptocoin is a library for interfacing with Bitcoin and Bitcoin-like coins}
  spec.description   = %q{Cryptocoin is a library for processing messages and information from a cryptocoin network, such as a packet of information, and creating useful wrappers for such data.}
  spec.homepage      = "https://github.com/joshuasmock/cryptocoin"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
