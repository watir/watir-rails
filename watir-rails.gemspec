# -*- encoding: utf-8 -*-
require File.expand_path('../lib/watir/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jarmo Pertman"]
  gem.email         = ["jarmo.p@gmail.com"]
  gem.description   = %q{Use Watir (http://github.com/watir/watir) in Rails.}
  gem.summary       = %q{Use Watir (http://github.com/watir/watir) in Rails.}
  gem.homepage      = "http://github.com/watir/watir-rails"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "watir-rails"
  gem.require_paths = ["lib"]
  gem.license       = "MIT"
  gem.version       = Watir::Rails::VERSION
  gem.required_ruby_version = ">= 2.2.0"

  gem.add_dependency "rack"
  gem.add_dependency "rails", ">= 3.1"
  # Rails dependency since 5.0
  gem.add_dependency "concurrent-ruby", ">= 1.0"
  gem.add_dependency "watir", ">= 6.0.0.beta4"

  gem.add_development_dependency "yard"
  gem.add_development_dependency "redcarpet"
  gem.add_development_dependency "rspec", "~> 3.0"
  gem.add_development_dependency "appraisal"
end
