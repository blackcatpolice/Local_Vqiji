class Talk::Service
  attr_reader :user
  
  def initialize(user)
    @user = user
  end

  def feeds
    Talk::Feed.where(receiver_id: @user.id)
  end

  def sessions
    current_user.talk_sessions.includes(:group)
  end

  def to(session, text, opts = {})
    msg = session.say(text, opts)
    msg.feed_for(@user)
  end
  
  def to_user(receiver, text, options)
    session = Talk::Group.p2p_find_or_create_by(@user, receiver).session_for(@user)
    to(session, text, options)
  end
  
  def create_group(members, topic = nil)
    _members = Array.wrap(members)
    if (_members.length == 1)
      group = Talk::Group.p2p_find_or_create_by(@user, _members[0])
      group.restore_sessions! if group
    else
      begin # 创建讨论组会话
        group = Talk::Group.create!(creater: @user, topic: topic)
        add_members(group, _members)
      rescue => e
        group.destroy if group && group.persisted?
        raise e
      end
    end
    group
  end

  # 添加成员
  def add_members(group, users)
    Array.wrap(users).each do |user|
      group.add_member(user, @user, false)
      # group.notify_user_join(user, false)
    end
    group.save!
    # group.realtime_notifiy_message_changed()
  end

  # 删除会话组成员
  def delete_member!(group, user)
    raise Talk::Error, '您无权删除成员，因为您不是会话创建人！' if group.creater != @user
    member = group.sessions.where( :user_id => user.to_param ).first
    if member
      raise Talk::Error, '不能删除创建人！' if member.user == group.creater
      group.remove_member!(user)
    end
  end
  
  # 退出会话组
  def quit!(group)
    if session = group.session_for(@user)
      group.remove_session!(session)
      # 私信会话不发送
      group.notify_user_quit(user) unless group.p2p?
    end
  end
end
