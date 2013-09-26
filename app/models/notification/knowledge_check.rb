# encoding: utf-8
# 评论通知
#
class Notification::KnowledgeCheck < Notification::Base
  belongs_to :knowledge, class_name: 'Knowledge::Knowledge'
  
  index :user_id => 1, :knowledge_id => 1
    
  class << self
    def view_url(user = nil)
      '/knowledge/knowledges/my'
    end
  end
end
