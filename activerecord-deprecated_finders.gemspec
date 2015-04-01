# -*- encoding: utf-8 -*-
require File.expand_path('../lib/active_record/deprecated_finders/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "activerecord-deprecated_finders"
  gem.version       = ActiveRecord::DeprecatedFinders::VERSION

  gem.description   = %q{Deprecated finder APIs extracted from Active Record.}
  gem.summary       = %q{This gem contains deprecated finder APIs extracted from Active Record.}
  gem.homepage      = "https://github.com/rails/activerecord-deprecated_finders"
  gem.license       = 'MIT'

  gem.authors       = ["Jon Leighton"]
  gem.email         = ["j@jonathanleighton.com"]

  gem.files         = Dir["README.md", "lib/**/*.rb", "LICENSE"]
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'minitest',     '>= 3'
  gem.add_development_dependency 'activerecord', '>= 4.0.0.beta', '< 5'
  gem.add_development_dependency 'sqlite3',      '~> 1.3'
end
