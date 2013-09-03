# encoding: utf-8
# 培训未通过通知

class Notification::ElearnTrainingNotPass < Notification::Base
  belongs_to :training, class_name: 'Training'
  
  index :user_id => 1, :training_id => 1
  
  class << self
    def view_url(user = nil)
      url_helpers.elearn_trainings_path
    end
    
    def notify!(training_user)
      # 清除 通过/未通过 通知
      Notification::Base.where(
        :_type.in => Notification::ElearnTrainingPassed._types + Notification::ElearnTrainingNotPass._types,
        :user_id => training_user.user_id,
        :training_id => training_user.training_id
      ).destroy_all
      create!(:user => training_user.user, :training => training_user.training).deliver
    end
  end
end
