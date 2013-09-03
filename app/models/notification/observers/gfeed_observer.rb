# encoding: utf-8

# 重要微博
class Notification::Observers::GfeedObserver < Mongoid::Observer
  observe :gfeed

  def after_create(feed)
    if feed.is_top
      Resque::enqueue(Tweet::TopTweetNotificationDispatcher, feed.id)
    end
  end

  def after_destroy(feed)
    Notification::TopTweet.where(:feed_id => feed.id).destroy_all
  end
end
