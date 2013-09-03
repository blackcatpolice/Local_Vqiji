# encoding: utf-8
# 问题解决通知
#
class Notification::AdvisoryQuestionSolved < Notification::Base
  belongs_to :question, class_name: 'Question'
  
  index :user_id => 1, :question_id => 1
  
  class << self
    def view_url(user = nil)
      '/advisory/experts/solved'
    end
  end
end
