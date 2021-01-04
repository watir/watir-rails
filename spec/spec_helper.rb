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

require 'watir/rails'

framework = case File.basename(ENV.fetch('BUNDLE_GEMFILE', '')).sub(/\.gemfile\z/, '')
            when 'hanami' then 'hanami'
            when 'sinatra' then 'sinatra'
            else 'rails'
            end

Bundler.require(framework)

require_relative '../dummy/config/environment' if framework == 'rails'

# Make sure that dummy selenium-webdriver driver is loaded in specs
require 'support/selenium_webdriver'
# Reset watir-rails state after examples run
require 'support/reset_watir_rails'

RSpec.configure do |c|
  c.color = true
  c.order = :random

  c.filter_run_excluding rails: framework != 'rails'

  if framework != 'rails'
    config_path = case framework
                  when 'hanami' then '../dummy/config.ru'
                  when 'sinatra' then './fixtures/sinatra_app'
                  else raise 'No framework under test found'
                  end
    c.before { Watir::Rails.app_path = File.expand_path(config_path, __dir__) }
  end
end
