# encoding: utf-8
# 微博提到通知
#
class Notification::TweetMention < Notification::Base
  belongs_to :tweet, class_name: 'Tweet'
  
  index :user_id => 1, :tweet_id => 1
  
  class << self
    def view_url(user = nil)
      '/my/mention/tweets'
    end
  end
end
