# encoding: utf-8
# 微博转发通知

class Notification::Observers::TweetObserver < Mongoid::Observer
  observe :tweet

  def after_create(tweet)
    # 发送转发通知
    if (tweet.reforigin && (tweet.reforigin.sender != tweet.sender))
      Notification::Repost.create!(:user => tweet.reforigin.sender, :tweet => tweet).deliver
    end
  end

  def after_destroy(tweet)
    if (tweet.reforigin&& (tweet.reforigin.sender != tweet.sender))
      if ( Notification::Repost.where(:user_id => tweet.reforigin.sender_id, :tweet_id => tweet.id).destroy_all > 0 )
        tweet.reforigin.sender.notification.trigger_count_changed!
      end
    end
  end
end
