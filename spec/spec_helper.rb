require "simplecov"

if ENV["CI"]
  require "simplecov-lcov"

  SimpleCov::Formatter::LcovFormatter.config do |c|
    c.report_with_single_file = true
    c.single_report_path = "coverage/lcov.info"
  end

  SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter
end

SimpleCov.start

# Make sure that fake watir gems are loaded for specs.
$LOAD_PATH.unshift File.expand_path("support", File.dirname(__FILE__))

require "watir/rails"

RSpec.configure do |c|
  c.color = true
  c.order = :random
end
