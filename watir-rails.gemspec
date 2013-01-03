# -*- encoding: utf-8 -*-
require File.expand_path('../lib/watir/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jarmo Pertman"]
  gem.email         = ["jarmo.p@gmail.com"]
  gem.description   = %q{Add support for Watir (http://github.com/watir/watir) in Rails.}
  gem.summary       = %q{Add support for Watir (http://github.com/watir/watir) in Rails.}
  gem.homepage      = "http://github.com/watir/watir-rails"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "watir-rails"
  gem.require_paths = ["lib"]
  gem.version       = Watir::Rails::VERSION

  gem.add_dependency "rack"
  gem.add_dependency "rails"
  gem.add_dependency "watir-webdriver"

  gem.add_development_dependency "yard"
  gem.add_development_dependency "redcarpet"
end
