# encoding: utf-8
# 评论提到通知
#
class Notification::CommentMention < Notification::Base
  belongs_to :comment, class_name: 'Comment'
  
  index :user_id => 1, :comment_id => 1
  
  class << self
    def view_url(user = nil)
      '/my/mention/comments'
    end
  end
end
