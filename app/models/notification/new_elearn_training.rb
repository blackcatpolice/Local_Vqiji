# encoding: utf-8
# 新培训通知
#
class Notification::NewElearnTraining < Notification::Base
  belongs_to :training, class_name: 'Training'
  
  index :user_id => 1, :training_id => 1
  
  class << self
    def view_url(user = nil)
      '/elearn/trainings'
    end
  end
end
