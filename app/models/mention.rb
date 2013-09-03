# encoding: utf-8

# 提到
class Mention
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  
  belongs_to :user, class_name: 'User', inverse_of: :mentions#, counter_cache: true # 被通知提到的用户
  belongs_to :target, polymorphic: true # 提到目标（微博/评论）

  validates_presence_of :user, :target
  
  index :user_id => 1
  index :user_id => 1, :created_at => -1
  
  index :user_id => 1, :target_type => 1, :target_id => 1
  index :user_id => 1, :target_type => 1, :target_id => 1, :created_at => -1
end
