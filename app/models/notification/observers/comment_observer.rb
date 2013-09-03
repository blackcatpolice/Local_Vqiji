# encoding: utf-8
class Notification::Observers::CommentObserver < Mongoid::Observer
  observe :comment
  
  def after_create(comment)
    # 给被回复评论作者发送通知
    if comment.reply? && ( comment.sender != comment.refsender  )
      Notification::ReplayComment.create!(:user => comment.refsender, :comment => comment).deliver
    end
    
    # 向微博作者发送评论通知
    #  1. 不发送通知给自己
    #  2. 如果已经收到了回复提醒，则不发送新评论通知
    if ( comment.sender != comment.tweeter) \
      && !( comment.reply? && ( comment.refsender == comment.tweeter ) )
      Notification::Comment.create!(:user => comment.tweeter, :comment => comment).deliver
    end
  end
  
  def after_destroy(comment)
    if comment.reply? && comment.refsender && ( comment.sender != comment.refsender  )
      if ( Notification::ReplayComment.where(:user_id => comment.refsender_id, :comment_id => comment.id).destroy_all > 0 )
        comment.refsender.notification.trigger_count_changed!
      end
    end

    if ( comment.sender != comment.tweeter ) && comment.tweeter
      if ( Notification::Comment.where(:user_id => comment.tweeter_id, :comment_id => comment.id).destroy_all > 0 )
        comment.tweeter.notification.trigger_count_changed!
      end
    end
  end
end
