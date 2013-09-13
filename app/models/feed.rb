# encoding: utf-8

# 收到的微博引用副本

class Feed
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  
  belongs_to :tweet, class_name: 'Tweet', inverse_of: :feeds
  belongs_to :receiver, class_name: 'User', inverse_of: :feeds # 接收人
  belongs_to :sender, class_name: 'User', inverse_of: nil  # 发送人 (CACHE)
  
  field :follow_type, type: Integer, default: Followship::FOLLOW_TYPE_DEFAULT
  field :read_at, type: DateTime

  validates_presence_of :receiver, :tweet
  validates_uniqueness_of :tweet, scope: :receiver_id

  before_create do |feed|
    # 填充字段
    feed.sender = tweet.sender
    feed.created_at = tweet.created_at
  end
  
  after_destroy do |feed|
    _decrement_tweet_readers_count
  end

  # indexes
  index :tweet_id => 1
  index({ :tweet_id => 1, :receiver_id => 1 }, { :unique => true })

  index :receiver_id => 1
  index :receiver_id => 1, :follow_type => 1
  index :receiver_id => 1, :created_at => -1
  index :receiver_id => 1, :follow_type => 1, :created_at => -1
  index :created_at => -1

  default_scope desc(:created_at) # 默认时间倒序排序
  scope :after, ->(time) { where(:created_at.gt => time) }
  scope :readed, -> { where(:read_at.ne => nil) }
  scope :unread, -> { where(:read_at => nil) }

  class << self
    def find_by_receiver_id(receiver_id)
      where(:receiver_id => receiver_id)
    end

    def find_by_tweet_id(tweet_id)
      where(:tweet_id => tweet_id)
    end
  end
  
  # 已读？
  def readed?
    !!read_at
  end
  
  # 标记为已读
  def read!
    if !readed?
      update_attribute(:read_at, Time.now.utc)
      Tweet.increment_counter(:readers_count, tweet_id)
    end
  end
  
  # 标记为未读
  def unread!
    _decrement_tweet_readers_count
  end
  
  private
  
  def _decrement_tweet_readers_count
    if readed?
      update_attribute(:read_at, nil)
      Tweet.decrement_counter(:readers_count, tweet_id)
    end
  end

end
