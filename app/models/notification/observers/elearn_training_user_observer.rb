# encoding: utf-8

class Notification::Observers::ElearnTrainingUserObserver < Mongoid::Observer
  observe :training_user
  
  def after_create(training_user)
    if ((training = training_user.training) && training.released && (user = training_user.user))
      # 发送新培训通知
      Notification::NewElearnTraining.create(
        :user => user,
        :training => training
      ).deliver
    end
  end
  
  def after_destroy(training_user)
    if ((training = training_user.training) && (user = training_user.user))
    # 删除新培训通知
      if ( Notification::NewElearnTraining.where(
        :user_id => user.id,
        :training_id => training.id
      ).destroy_all > 0 )
        user.notification.trigger_count_changed!
      end
    end
  end
end
