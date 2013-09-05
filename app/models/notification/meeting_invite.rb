# encoding: utf-8
# 工作组加入通知
#
class Notification::MeetingInvite < Notification::Base
  belongs_to :meeting, class_name: 'Meeting::Meeting'

  index(:user_id => 1, :meeting_id => 1)

  scope :to_user, ->(user) { where(:user_id => user.to_param) }
  scope :of_meeting, ->(meeting) { where(:meeting_id => meeting.to_param) }
  
  class << self
    def notify!(meeting_member)
      create!(:user => meeting_member.user, :meeting => meeting_member.meeting).deliver unless meeting_member.is_creator
    end
    
    def for(user, meeting)
      to_user(user).of_meeting(meeting)
    end
    
    def view_url(user = nil)
      url_helpers.invited_meeting_meetings_path
    end
  end
end
