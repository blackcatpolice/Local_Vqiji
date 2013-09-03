# encoding: utf-8

class Notification::Observers::GroupMemberObserver < Mongoid::Observer
  observe :group_member
  
  def after_create(group_member)
    if (user = group_member.user) && (group = group_member.group) && (user != group.creator)
      Notification::GroupJoin.notify!(group_member)
    end
  end

  def before_destroy(group_member)
    if (user = group_member.user) && (group = group_member.group)
      user.notification.delete!( Notification::TopTweet.for(user, group) )
      user.notification.delete!( Notification::GroupJoin.for(user, group) )
    end
  end
end
