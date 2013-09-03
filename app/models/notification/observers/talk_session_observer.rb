# encoding: utf-8

class Notification::Observers::TalkSessionObserver < Mongoid::Observer
  observe 'talk/session'
  
  def after_create(talk_session)
    return if talk_session.p2p?
    if ( (user = talk_session.user) && (group = talk_session.group) )
      return if (group.creater == user)
      Notification::TalkGroupJoin.notify!(talk_session)
    end
  end

  def after_destroy(talk_session)
    if ( (user = talk_session.user) && (group = talk_session.group) )
      notifications = Notification::TalkGroupJoin.for(user, group)
      user.notification.delete!( notifications )
    end
  end
end
