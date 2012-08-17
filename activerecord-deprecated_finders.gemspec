# -*- encoding: utf-8 -*-
require File.expand_path('../lib/active_record/deprecated_finders/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jon Leighton"]
  gem.email         = ["j@jonathanleighton.com"]
  gem.description   = %q{This gem contains deprecated finder APIs extracted from Active Record.}
  gem.summary       = %q{This gem contains deprecated finder APIs extracted from Active Record.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "activerecord-deprecated_finders"
  gem.require_paths = ["lib"]
  gem.version       = ActiveRecord::DeprecatedFinders::VERSION

  gem.add_development_dependency 'minitest',     '>= 3'
  gem.add_development_dependency 'activerecord', '~> 4.0.0.beta'
  gem.add_development_dependency 'sqlite3',      '~> 1.3'
end
