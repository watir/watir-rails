require "simplecov"
require 'coveralls'

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start

require "watir/rails"

RSpec.configure do |c|
  c.color = true
  c.order = :random
end
