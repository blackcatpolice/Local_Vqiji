# encoding: utf-8

require 'resque'
require 'resque/server'

resque_config = YAML.load_file("#{Rails.root}/config/resque.yml")

Resque::Server.use(Rack::Auth::Basic) do |user, password|
  (user == resque_config['user']) && (password == resque_config['password'])
end

Resque.redis = $redis
