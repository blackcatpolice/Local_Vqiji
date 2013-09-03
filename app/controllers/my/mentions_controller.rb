# encoding: utf-8

class My::MentionsController < WeiboController

  private
  
  def clear_notification
    #current_user.notification.reset!(Notification::TweetMention)
    #current_user.notification.reset!(Notification::CommentMention)
  end
end
