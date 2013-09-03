# encoding: utf-8

require 'redis'
require 'redis-namespace'

redis_config = YAML.load_file("#{Rails.root}/config/redis.yml")

$redis = Redis::Namespace.new('weibo',
  {
    redis: Redis.connect(url: redis_config[Rails.env])
  }
)
