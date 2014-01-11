# coding: utf-8
Gem::Specification.new do |spec|
  spec.name          = 'joiner'
  spec.version       = '0.1.0'
  spec.authors       = ['Pat Allan']
  spec.email         = ['pat@freelancing-gods.com']
  spec.summary       = %q{Builds ActiveRecord joins from association paths}
  spec.description   = %q{Builds ActiveRecord outer joins from association paths and provides references to table aliases.}
  spec.homepage      = 'https://github.com/pat/joiner'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ['lib']
end
