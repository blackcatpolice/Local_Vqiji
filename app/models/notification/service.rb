class Notification::Service
  attr_reader :user
  
  def initialize(user)
    @user = user
  end

  # 分组的未读通知
  def map
    @user.notifications.group_by { |n| n.class }
  end
  
  # 重置通知
  def reset!(type = Notification::Base, trigger_changed = true)
    if (( type.where(:user_id => @user.id).destroy_all > 0 ) && trigger_changed)
      trigger_count_changed!
    end
  end
  
  # 移除通知
  def delete!(notifications, trigger_changed = true)
    _destroyable = Array.wrap(notifications).select { |n| (n.user == @user) }
    if _destroyable.any?
      Notification::Base.where(:_id.in => _destroyable.collect(&:id)).destroy_all
      trigger_count_changed! if trigger_changed
    end
  end
  
  # 获取未读通知总数
  def count(type = Notification::Base)
    type.where(:user_id => @user.id).count
  end

  # 发出 count changed 通知
  def trigger_count_changed!(new_count = nil)
    Notification::CountChangedTrigger.new(new_count || count).throw_to!(Realtime::UserReceiver[@user])
  end
end
