# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gull/version'

Gem::Specification.new do |spec|
  spec.name          = 'gull'
  spec.version       = Gull::VERSION
  spec.authors       = ['Seth Deckard']
  spec.email         = ['seth@deckard.me']
  spec.summary       = 'Client for parsing NOAA/NWS alerts, warnings, and watches.'
  spec.description   = 'Client for parsing NOAA/NWS alerts, warnings, and watches.'
  spec.homepage      = 'https://github.com/sethdeckard/gull'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'httpclient'
  spec.add_runtime_dependency 'nokogiri', '>= 1.6.8'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '>=3.0'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'webmock'
end
