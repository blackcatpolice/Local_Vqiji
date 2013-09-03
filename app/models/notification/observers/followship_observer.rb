# encoding: utf-8
# 关注
class Notification::Observers::FollowshipObserver < Mongoid::Observer
  observe :followship
  
  def after_create(followship)
    return if followship.whisper? # 悄悄关注不发送通知
    Notification::Fan.create!(:user => followship.followed, :followship => followship).deliver
  end
  
  # 关注取消后删除通知
  def after_destroy(followship)
    return if followship.whisper? # 悄悄关注不发送通知
    if ( Notification::Fan.where(:user_id => followship.followed_id, :followship_id => followship.id).destroy_all > 0 )
      followship.followed.notification.trigger_count_changed!
    end
  end
end
