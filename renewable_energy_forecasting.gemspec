# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'repf/version'

Gem::Specification.new do |spec|
  spec.name          = "renewable_energy_forecasting"
  spec.version       = REPF::VERSION
  spec.authors       = ["Katrina Haines"]
  spec.email         = ["katrinahaines@gmail.com"]

  spec.summary       = %q{Proof of concept implementation of a system to predict renewable energy outputs using neural network based models.}
  spec.description   = %q{This is a system to, with knowledge of a small scale provider's installation type and rated max capacity, produce reliable near and long term estimates of power generation that factor in weather patterns as well as solar radiation patterns, using a neural network to create an accurate model of the renewable power installation's performance under diverse environmental conditions.}
  spec.homepage      = "http://katrina-isef.swiftcore.org"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
end
