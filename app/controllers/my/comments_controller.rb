# encoding: utf-8

# 我的评论
class My::CommentsController < WeiboController
  # 发出的评论
  def sends
    @comments = current_user.comments.includes(:tweeter, :sender, :tweet)
                            .paginate(:page => params[:page], :per_page => 20)
    render 'list'
  end

  # 收到的评论
  def receives
    @comments = current_user.received_comments.includes(:tweeter, :sender, :tweet)
                            .paginate(:page => params[:page], :per_page => 20)
    render 'list'
    current_user.notification.reset!(Notification::Comment)
    current_user.notification.reset!(Notification::ReplayComment)
  end
end
