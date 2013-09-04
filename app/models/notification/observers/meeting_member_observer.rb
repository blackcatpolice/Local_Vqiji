# encoding: utf-8

class Notification::Observers::MeetingMemberObserver < Mongoid::Observer
  observe Meeting::MeetingMember
  
  def after_create(meeting_member)
    # if (user = group_member.user) && (group = group_member.group) && (user != group.creator)
      Notification::MeetingInvite.notify!(meeting_member)
    # end
  end

  def before_destroy(meeting_member)
    if (user = group_member.user) && (group = group_member.group)
      user.notification.delete!( Notification::TopTweet.for(user, group) )
      user.notification.delete!( Notification::GroupJoin.for(user, group) )
    end
  end
end
