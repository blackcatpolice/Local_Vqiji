# encoding: utf-8

class Notification::Observers::AdvisoryQuestionObserver < Mongoid::Observer
  observe :question
  
  def after_create(question)
    # 发送新问题通知给专家
    if (question.expert && (user = question.expert.user))
      Notification::NewAdvisoryQuestion.create(
        :user => user,
        :question => question
      ).deliver
    end
  end
  
  def after_destroy(question)
    if (question.expert && (user = question.expert.user))
      # 删除新问题通知
      if ( Notification::NewAdvisoryQuestion.where(
        :user_id => user.id,
        :question_id => question.id
      ).destroy_all > 0 )
        user.notification.trigger_count_changed!
      end
      
      # 删除已解决通知
      if question.solved
        if ( Notification::AdvisoryQuestionSolved.where(
          :user_id => user.id,
          :question_id => question.id
        ).destroy_all > 0 )
          user.notification.trigger_count_changed!
        end
      end
    end
  end
  
  def around_update(question)
    # 当 Question 的 solved 状态被改变为 true 后发送问题已解决通知給专家
    if (question.solved_changed? && question.solved)
      yield
      Notification::AdvisoryQuestionSolved.create(
        :user => question.expert.user,
        :question => question
      ).deliver
    else
      yield
    end
  end
end
