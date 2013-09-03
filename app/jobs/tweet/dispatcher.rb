# encoding: utf-8
 
class Tweet
  # 分发 tweet 给每个关注者
  class Dispatcher
    @queue = :'tweet-dispatcher'
 
    def self.perform(tweet_id)
      Tweet.find(tweet_id).dispatch
    end
  end
end
