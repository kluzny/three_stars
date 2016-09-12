# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'three_stars/version'

Gem::Specification.new do |spec|
  spec.name          = 'three_stars'
  spec.version       = ThreeStars::VERSION
  spec.authors       = ['Kyle Luzny']
  spec.email         = ['kluzny@gmail.com']

  spec.summary       = 'Extends ActiveRecord to add methods for '\
    'database index recommendations matching specific queries'
  spec.homepage      = 'https://github.com/kluzny/three_stars'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org.
  # To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or
  # delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required ' \
      'to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`
                       .split("\x0")
                       .reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'byebug', '~> 9.0.0'
  spec.add_development_dependency 'awesome_print', '~> 1.7.0'
  spec.add_runtime_dependency 'pg_query', '~> 0.11.2'
end
