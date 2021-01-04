use Rack::Auth::Basic do |username, password|
  username == 'watir' && password == 'rails'
end

run Rack::Builder.parse_file(File.expand_path('sinatra_app', __dir__)).first
