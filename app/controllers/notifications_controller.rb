class NotificationsController < WeiboController
  def index
    render :nothing => true
  end

  def count
    render :json => current_user.notification.count
  end

  def nb
    @map = current_user.notification.map
    render :layout => false
  end
  
  def reset
    current_user.notification.reset!
    render :nothing => true
  end
end
