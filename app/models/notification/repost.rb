# encoding: utf-8
# 转发通知
#
class Notification::Repost < Notification::Base
  belongs_to :tweet, class_name: 'Tweet'
  
  index :user_id => 1, :tweet_id => 1
end
