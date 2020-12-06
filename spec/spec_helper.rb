require 'simplecov'

if ENV['CI']
  require 'simplecov-lcov'

  SimpleCov::Formatter::LcovFormatter.config do |c|
    c.report_with_single_file = true
    c.single_report_path = 'coverage/lcov.info'
  end

  SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter

  # HACK: https://github.com/fortissimo1997/simplecov-lcov/pull/25
  unless SimpleCov.respond_to?(:branch_coverage?)
    def SimpleCov.branch_coverage?
      false
    end
  end
end

SimpleCov.start do
  enable_coverage :branch if respond_to?(:enable_coverage)
  add_filter %r{^/spec/}
end

require_relative 'dummy/config/environment'

require 'watir/rails'

# Make sure that dummy selenium-webdriver driver is loaded in specs
require 'support/selenium_webdriver'
# Reset watir-rails state after examples run
require 'support/reset_watir_rails'

RSpec.configure do |c|
  c.color = true
  c.order = :random
end
