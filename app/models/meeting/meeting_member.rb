# encoding: utf-8

# 会议成员
class Meeting::MeetingMember
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Handler::Common
  
  PARTICIPATE_STATUS = {0 => '参与会议', 1 => '缺席会议', 2 => '待定'}

  field :is_creator, :type => Boolean, :default => false # 是否为创建者
  field :participate_status, :type => Integer, :default => 0 # 与会状态
  field :remark, :type => Integer # 备注

  belongs_to :user, :class_name => 'User', :inverse_of => :meeting_members  # 用户
  belongs_to :meeting, :class_name => 'Meeting::Meeting', :inverse_of => :members, :counter_cache => true  # 工作组

  
  validates :user, presence: true, uniqueness: { scope: :group_id }
  validates :meeting, presence: true
  validates :participate_status, inclusion: { in: PARTICIPATE_STATUS.keys }
end
