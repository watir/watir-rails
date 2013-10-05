require "simplecov"
require 'coveralls'

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start

# Make sure that fake watir gems are loaded for specs.
$LOAD_PATH.unshift File.expand_path("support", File.dirname(__FILE__))

require "watir/rails"

RSpec.configure do |c|
  c.color = true
  c.order = :random
end
