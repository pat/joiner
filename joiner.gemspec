# coding: utf-8
Gem::Specification.new do |spec|
  spec.name          = 'joiner'
  spec.version       = '0.3.4'
  spec.authors       = ['Pat Allan']
  spec.email         = ['pat@freelancing-gods.com']
  spec.summary       = %q{Builds ActiveRecord joins from association paths}
  spec.description   = %q{Builds ActiveRecord outer joins from association paths and provides references to table aliases.}
  spec.homepage      = 'https://github.com/pat/joiner'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activerecord', '>= 4.1.0'

  spec.add_development_dependency 'combustion',  '~> 0.7'
  spec.add_development_dependency 'rails',       '>= 4.1.2'
  spec.add_development_dependency 'rspec-rails', '~> 3'
  spec.add_development_dependency 'sqlite3',     '~> 1.3.8'
end
