require 'bundler/setup'
require 'hanami/setup'
require_relative '../apps/web/application'

Hanami.configure do
  mount Web::Application, at: '/'

  environment :development do
    # See: https://guides.hanamirb.org/projects/logging
    logger level: :debug
  end
end
