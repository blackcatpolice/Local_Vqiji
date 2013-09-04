# encoding: utf-8

# 会议成员
class Meeting::MeetingMember
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Handler::Common
  
  INVITING = -1
  PARTICIPATE = 0
  ABSENCE = 1
  PENDING = 2

  PARTICIPATE_STATUS = {INVITING => '邀请中', 
                        PARTICIPATE => '参与会议',
                        ABSENCE => '缺席会议',
                        PENDING => '待定'}

  field :is_creator, :type => Boolean, :default => false # 是否为创建者
  field :participate_status, :type => Integer, :default => INVITING # 与会状态
  field :remark, :type => Integer # 备注

  belongs_to :user, :class_name => 'User', :inverse_of => :meeting_members  # 用户
  belongs_to :meeting, :class_name => 'Meeting::Meeting', :inverse_of => :members, :counter_cache => true  # 工作组

  
  validates :user, presence: true, uniqueness: { scope: :group_id }
  validates :meeting, presence: true
  validates :participate_status, inclusion: { in: PARTICIPATE_STATUS.keys }

  scope :participated, where(:participate_status => PARTICIPATE)
  scope :absenced, where(:participate_status => ABSENCE)
  scope :pending, where(:participate_status => PENDING)

  scope :attending_meeting, ->(status){
    where(:participate_status => status)
  }
end
