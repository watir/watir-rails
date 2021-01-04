require 'sinatra/base'

class SinatraApp < Sinatra::Base
  set :raise_errors, true
  set :show_exceptions, false

  get '/tests' do
    'Hello world!'
  end

  get '/tests/raise_error' do
    raise 'watir-rails test message'
  end
end
