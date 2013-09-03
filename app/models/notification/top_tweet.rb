# encoding: utf-8
# 重要微博通知
#
class Notification::TopTweet < Notification::Base
  belongs_to :feed, class_name: 'Gfeed'
  
  # helper fields
  belongs_to :_tweet, class_name: 'Tweet'
  belongs_to :_group, class_name: 'Group'

  before_create do |notification|
    notification._tweet = notification.feed.tweet
    notification._group = notification.feed.group
  end
  
  index :user_id => 1, :feed_id => 1
  
  scope :to_user, ->(user) { where(:user_id => user.to_param) }
  scope :of_group, ->(group) { where(:_group_id => group.to_param) }
  
  class << self  
    def dispatch(feed)
      feed.group.members
        .where(:user_id.ne => feed._sender_id) # 不发送给自己
        .includes(:user).each do |member|
          Notification::TopTweet.create!(:user => member.user, :feed => feed).deliver
        end
    end

    def unreads_count_of(user, group)
      to_user(user).of_group(group).count
    end
    
    def for(user, group)
      to_user(user).of_group(group)
    end
    
    def view_url(user = nil)
      url_helpers.mine_groups_path
    end
  end
end
