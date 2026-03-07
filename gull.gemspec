# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
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
  spec.required_ruby_version = '>= 3.1'

  spec.metadata = {
    'source_code_uri' => 'https://github.com/sethdeckard/gull',
    'changelog_uri' => 'https://github.com/sethdeckard/gull/blob/master/CHANGELOG.md',
    'bug_tracker_uri' => 'https://github.com/sethdeckard/gull/issues'
  }

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(AGENTS|CLAUDE)\.md$})
  end
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '>= 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'webmock'
end
