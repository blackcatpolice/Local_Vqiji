# encoding: utf-8

# 工作组成员
class GroupMember
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Handler::Common

  belongs_to :user, :class_name => 'User', :inverse_of => :group_members 	# 用户
  belongs_to :group, :class_name => 'Group', :inverse_of => :members, :counter_cache => true	# 工作组

  field :is_admin, :type => Boolean, :default => false # 是否为管理员
  
  validates :user, presence: true, uniqueness: { scope: :group_id }
  validates :group, presence: true

  scope :group_scope, ->(group) { where(:group_id => group.to_param) }
  scope :user_scope, ->(user) { where(:user_id => user.to_param) }
  scope :admin_scope, where(:is_admin => true)
  
  index :user_id => 1
  index :group_id => 1
  index({ :group_id => 1, :user_id => 1 }, { :unique => true })
  index :group_id => 1, :is_admin => 1
  index :group_id => 1, :user_id => 1, :is_admin => 1
end
