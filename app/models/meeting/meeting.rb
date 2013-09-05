# encoding: utf-8

# 会议
class Meeting::Meeting
  include Mongoid::Document
  include Mongoid::Timestamps

	# fields
	field :subject, :type => String # 会议主题
  field :summary, :type => String # 会议摘要
	field :location,:type => String # 会议地点
  field :start_date, :type => Time # 开始日期
  field :end_date, :type => Time  # 结束日期

	belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'	# 创建者
	has_many   :members, :class_name => 'Meeting::MeetingMember', inverse_of: :meeting, :dependent => :destroy # 包含成员
	field :members_count, :type => Integer, :default => 0 # 成员数量

	validates_presence_of :subject, :creator, :start_date

  after_create do |meeting|
    Meeting::MeetingMember.create!(:meeting => self, :user_id => self.creator_id, :is_creator => true)
  end


  # 邀请参加会议
  def invite_users(user_ids)
    exists_ids = members.where(:user_id.in => user_ids).distinct(:_id)
    User.where(:_id.in => (user_ids - exists_ids)).each do |user|
      meeting_member = Meeting::MeetingMember.create!(:meeting => self, :user_id => user.id)
    end
  end

  
end