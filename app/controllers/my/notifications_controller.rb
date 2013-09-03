## encoding: utf-8
# 通知
class My::NotificationsController < WeiboController
    #layout :nil
   def index
     @notifications =  Notification::Base.desc("created_at")
      .where(:receiver_id => current_user.id.to_s)
     
     respond_to do |format|
       format.html # index.html.erb
       format.json {  render json: @notifications }
     end
   end
end
