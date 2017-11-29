# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'oriented/version'

Gem::Specification.new do |spec|
  spec.name          = "oriented"
  spec.version       = Oriented::VERSION
  spec.authors       = ["Glenn Goodrich"]
  spec.email         = ["glenn.goodrich@gmail.com"]
  spec.description   = %q{A simple wrapper around OrientDB}
  spec.summary       = %q{Adds a declarative language around the OrientDB JRuby api}
  spec.homepage      = ""
  spec.license       = "MIT"
  spec.platform      = "java"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "orientdb", "~> 2.0"
  spec.add_runtime_dependency "activesupport"
  spec.add_runtime_dependency "activemodel"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~>2.13", "< 2.14.0"
  spec.add_development_dependency "pry"
end
