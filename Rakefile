# Skip list was generated via shellscript, using ruby-2.5:
# set -e
# for BUNDLE_GEMFILE in ./gemfiles/*.gemfile; do
# export BUNDLE_GEMFILE=${BUNDLE_GEMFILE}
#     rm -f ${BUNDLE_GEMFILE}.lockfile && bundle _1.17.3_ install && bundle exec rails --help
# done | grep \\--skip- | sed -e 's@.*\--skip-\([a-z\-]*\)\].*@\1@g' | sort -u
RAILS_SKIP_ARGUMENTS = %w[
  action-cable
  action-mailbox
  action-mailer
  action-text
  action-view
  active-record
  active-storage
  bootsnap
  bundle
  coffee
  gemfile
  git
  javascript
  keeps
  listen
  namespace
  puma
  spring
  sprockets
  system-test
  test
  test-unit
  turbolinks
  webpack-install
  yarn
].freeze

desc 'Creates dummy app for testing'
task :create_dummy_app do
  app_path = File.expand_path('spec/dummy', __dir__)

  FileUtils.rm_rf(app_path)

  skip_args = RAILS_SKIP_ARGUMENTS.map { |arg| "--skip-#{arg}" }

  raise 'Cannot create dummy app' unless system('bundle', 'exec', 'rails', 'new', app_path, *skip_args)

  fixtures_path = File.expand_path('spec/fixtures/dummy', __dir__)

  FileUtils.cp_r("#{fixtures_path}/.", app_path)
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task default: %i[create_dummy_app spec]
task release: %i[create_dummy_app spec]
require 'bundler/gem_tasks'

require 'yard'
YARD::Rake::YardocTask.new
