# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cucumber/blendle/version'

Gem::Specification.new do |spec|
  spec.name     = 'cucumber-blendle-steps'
  spec.version  = Cucumber::BlendleSteps::VERSION
  spec.authors  = ['Jean Mertz']
  spec.email    = %w(jean@blendle.com)
  spec.summary  = 'Cucumber steps used by all of Blendle Ruby projects'
  spec.homepage = 'https://www.blendle.com'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = %w(lib)

  spec.add_dependency 'activesupport'
  spec.add_dependency 'cucumber'
  spec.add_dependency 'halidator'
  spec.add_dependency 'hyperresource'
  spec.add_dependency 'json_spec'
  spec.add_dependency 'minitest'
  spec.add_dependency 'rack-test'
  spec.add_dependency 'rack'
  spec.add_dependency 'rspec-expectations'
  spec.add_dependency 'sequel'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'sequel'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'webmachine'
end
