# encoding: utf-8
# 提到
class Notification::Observers::MentionObserver < Mongoid::Observer
  observe :mention

  def after_create(mention)
    if mention.target.is_a?(Tweet)
      Notification::TweetMention.create!(:user => mention.user, :tweet => mention.target).deliver
    elsif mention.target.is_a?(Comment)
      Notification::CommentMention.create!(:user => mention.user, :comment => mention.target).deliver
    end
  end

  def after_destroy(mention)
    if mention.target.is_a?(Tweet)
      if ( Notification::TweetMention.where(:user_id => mention.user_id, :tweet_id => mention.target_id).destroy_all > 0 )
        mention.user.notification.trigger_count_changed!
      end
    elsif mention.target.is_a?(Comment)
      if ( Notification::CommentMention.where(:user_id => mention.user_id, :comment_id => mention.target_id).destroy_all > 0 )
        mention.user.notification.trigger_count_changed!
      end
    end
  end
end
