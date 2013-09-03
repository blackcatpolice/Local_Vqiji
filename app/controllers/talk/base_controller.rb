# encoding: utf-8

class Talk::BaseController < WeiboController
  
  helper_method :talk_sessions
  
  def talk_sessions
    current_user.talk_sessions.includes(:group)
  end
end
