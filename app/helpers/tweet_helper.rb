# encoding: utf-8

module TweetHelper
  def tweet_timeago(tweet, options = {})
    options[:href] = tweet_url(tweet)
    content_tag(:a, timeago(tweet.created_at), options)
  end
  
  def repost_preset(tweet)
    (tweet.reftweet && "//@#{ tweet.sender.name } :#{ tweet.text }") || ''
  end
end
