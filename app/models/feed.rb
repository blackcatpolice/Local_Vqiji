# encoding: utf-8

# 收到的微博引用副本

class Feed
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  belongs_to :tweet, class_name: 'Tweet', inverse_of: :feeds
  belongs_to :receiver, class_name: 'User', inverse_of: :feeds # 接收人
  belongs_to :sender, class_name: 'User', inverse_of: nil  # 发送人 (CACHE)
  field :follow_type, type: Integer, default: Followship::FOLLOW_TYPE_DEFAULT

  validates_presence_of :receiver, :tweet
  validates_uniqueness_of :tweet, scope: :receiver_id

  before_create do |feed|
    # 填充字段
    feed.sender = tweet.sender
    feed.created_at = tweet.created_at
  end

  # indexes
  index :tweet_id => 1
  index({ :tweet_id => 1, :receiver_id => 1 }, { :unique => true })

  index :receiver_id => 1
  index :receiver_id => 1, :follow_type => 1
  index :receiver_id => 1, :created_at => -1
  index :receiver_id => 1, :follow_type => 1, :created_at => -1
  index :created_at => -1

  scope :after, ->(time) { where(:created_at.gt => time) }  
  default_scope desc(:created_at) # 默认时间倒序排序

  class << self
    def find_by_receiver_id(receiver_id)
      where(:receiver_id => receiver_id)
    end

    def find_by_tweet_id(tweet_id)
      where(:tweet_id => tweet_id)
    end
  end
end
