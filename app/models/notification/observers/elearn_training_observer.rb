# encoding: utf-8

class Notification::Observers::ElearnTrainingObserver < Mongoid::Observer
  observe :training
  
  def around_update(training)
    # 培训发布后再发送通知
    if (training.released_changed? && training.released)
      yield
      training.users.includes(:user).each do |member|
        Notification::NewElearnTraining.create(
        :user => member.user,
        :training => training
      ).deliver
      end
    else
      yield
    end
  end
end
