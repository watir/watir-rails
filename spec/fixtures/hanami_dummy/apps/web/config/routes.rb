# Configure your routes here
# See: https://guides.hanamirb.org/routing/overview
#
# Example:
# get '/hello', to: ->(env) { [200, {}, ['Hello from Hanami!']] }
get '/tests', to: 'tests#index'
get '/tests/raise_error', to: 'tests#raise_error'
