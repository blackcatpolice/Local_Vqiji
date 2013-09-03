# encoding: utf-8
# 新问题通知
#
class Notification::NewAdvisoryQuestion < Notification::Base
  belongs_to :question, class_name: 'Question'
  
  index :user_id => 1, :question_id => 1
  
  class << self
    def view_url(user = nil)
      '/advisory/experts/unsolved'
    end
  end
end
