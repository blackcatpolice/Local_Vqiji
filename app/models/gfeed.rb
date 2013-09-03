# 分发到工作组的微博 Feed

class Gfeed
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  
  # fields
  belongs_to :tweet, class_name: 'Tweet', inverse_of: :gfeeds
  belongs_to :group, class_name: 'Group', inverse_of: :feeds
  field :is_top, type: Boolean, default: false # 置顶？
  
  # helper fields
  belongs_to :_sender, class_name: 'User', inverse_of: :gfeeds
  
  # validations
  validates_presence_of :tweet, :group
  # validates_uniqueness_of :tweet, :scope => :group_id
  
  # callbacks
  before_create do |feed|
    feed._sender = feed.tweet.sender # 设置发送人
  end
  
  after_create do |feed|
    feed.group.inc(:tweets_count, 1)
  end
  
  after_destroy do |feed|
    feed.group.inc(:tweets_count, -1)
  end
  
  # scopes
  default_scope desc(:created_at)
  scope :is_top, where(:is_top => true)
  
  # indexes
  index :group_id => 1, :created_at => -1
  index({ :tweet_id => 1, :group_id => 1 }, { :unique => true })
end
