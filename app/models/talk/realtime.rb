# encoding: utf-8

module Talk::Realtime
  CURRENT_SESSION_KEY = 'realtime/current_sessions'
  
  class << self
    # 获取当前会话
    def current_session(user)
      Talk::Session.where(_id: $redis.hget(CURRENT_SESSION_KEY, user.to_param)).first
    end
    
    # 设置当前会话
    def set_current_session(user, session)
      $redis.hset(CURRENT_SESSION_KEY, user.to_param, session.to_param)
    end
    
    # 清除当前会话
    def clear_current_session(user)
      set_current_session(user, nil)
    end
  end
end
