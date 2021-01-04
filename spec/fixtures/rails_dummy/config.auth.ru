use Rack::Auth::Basic do |username, password|
  username == 'watir' && password == 'rails'
end

run Rack::Builder.parse_file(File.expand_path('config.ru', __dir__)).first
