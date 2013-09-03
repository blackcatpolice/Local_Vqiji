# encoding: utf-8
 
class Tweet
  # 分发重要微博通知
  class TopTweetNotificationDispatcher
    @queue = :'top-tweet-notification-dispatcher'
 
    def self.perform(feed_id)
      Notification::TopTweet.dispatch( Gfeed.find(feed_id) )
    end
  end
end
