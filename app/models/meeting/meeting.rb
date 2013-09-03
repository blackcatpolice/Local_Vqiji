# encoding: utf-8

# 会议
class Meeting::Meeting
  include Mongoid::Document
  include Mongoid::Timestamps

	# fields
	field :subject, :type => String # 会议主题
  field :summary, :type => String # 会议摘要
	field :time,:type => Time # 会议时间
	field :location,:type => String # 会议地点

	belongs_to :creator, :class_name => 'User'	# 创建者
	has_many   :members, :class_name => 'Meeting::MeetingMember', inverse_of: :group, :dependent => :destroy # 包含成员
	field :members_count, :type => Integer, :default => 0 # 成员数量

	validates_presence_of :subject
	validates_presence_of :creator
end