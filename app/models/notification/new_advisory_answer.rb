# encoding: utf-8
# 新咨询回复通知
#
class Notification::NewAdvisoryAnswer < Notification::Base
  belongs_to :answer, class_name: 'Answer'
  
  index :user_id => 1, :answer_id => 1
  
  class << self
    def view_url(user = nil)
      # FIXME: 查看页面指示不明确
      '/advisory/questions/unsolved'
    end
  end
end
