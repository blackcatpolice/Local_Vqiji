module Talk::SessionsHelper
  
  # 标题
  def talk_session_title(session)
    if (group = session.group)
      if group.p2p # 单人会话时显示对方名字
        users = group.sessions.unscoped.includes(:user).collect(&:user)
        ((users[0] == current_user) ? users[1] : users[0]).name
      else
        session.topic || '<无主题>' # 多人会话时显示主题
      end
    end
  end
  
  # 二级标题
  def talk_session_subtitle(session)
    if (group = session.group)
      if group.p2p
        users = group.sessions.unscoped.includes(:user).collect(&:user)
        other = ((users[0] == current_user) ? users[1] : users[0])
        [
          other.department.try(:name) || '<部门未设置>',
          other.job || '<职位未设置>'
        ].join(' : ')
      else
        # FIXED: 显示出了所有人的名字，应最多只显示 4 个人的名字
        # 使用 distinct 时 limit 无效？
        user_ids = group.sessions.limit(4).pluck(:user_id)
        names = User.where(:_id.in => user_ids).distinct(:name)
        "#{ names.join(',') }...(#{ group.sessions_count })"
      end
    end
  end

  # 头像
  def talk_session_avatar_url(session)
    group = session.group
    if group.p2p  # 私信会话显示对方图标
      users = group.sessions.unscoped.includes(:user).collect(&:user)
      ((users[0] == current_user) ? users[1] : users[0]).avatar.v50x50.url
    else
      image_path('duoren.png')
    end
  end
end
