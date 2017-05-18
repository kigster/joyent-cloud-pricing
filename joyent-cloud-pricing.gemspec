# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pricing/version'

Gem::Specification.new do |spec|
  spec.name          = 'joyent-cloud-pricing'
  spec.version       = Joyent::Cloud::Pricing::VERSION
  spec.authors       = ['Konstantin Gredeskoul']
  spec.email         = ['kigster@gmail.com']
  spec.summary       = %q{Tools for calculating monthly and yearly price of infrastructure hosted on Joyent Public Cloud.}
  spec.description   = %q{Various set of tools and helpers to calculate infrastructure footprint and cost on Joyent Cloud. Supports commit discounts.}
  spec.homepage      = 'https://github.com/kigster/joyent-cloud-pricing'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})

  spec.require_paths = ['lib']

  spec.add_dependency 'nokogiri'
  spec.add_dependency 'hashie'
  spec.add_dependency 'colored2'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'simplecov'

  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-mocks'
  spec.add_development_dependency 'rspec-legacy_formatters'
end
