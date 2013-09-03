# encoding: utf-8
# 评论通知
#
class Notification::Comment < Notification::Base
  belongs_to :comment, class_name: 'Comment'
  
  index :user_id => 1, :comment_id => 1
    
  class << self
    def view_url(user = nil)
      '/my/comments/receives'
    end
  end
end
