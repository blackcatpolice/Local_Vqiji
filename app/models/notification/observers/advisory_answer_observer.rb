# encoding: utf-8

class Notification::Observers::AdvisoryAnswerObserver < Mongoid::Observer
  observe :answer
  
  def after_create(answer)
    if ((question = answer.question) && (user = question.owner))
      # 发送新回复通知
      Notification::NewAdvisoryAnswer.create(
        :user => user,
        :answer => answer
      ).deliver
    end
  end
  
  def after_destroy(answer)
    if ((question = answer.question) && (user = question.owner))
    # 删除新问题通知
      if ( Notification::NewAdvisoryAnswer.where(
        :user_id => user.id,
        :answer_id => answer.id
      ).destroy_all > 0 )
        user.notification.trigger_count_changed!
      end
    end
  end
end
