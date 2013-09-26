# encoding: utf-8

# 重要微博
class Notification::Observers::KnowledgeObserver < Mongoid::Observer
  observe 'knowledge/knowledge'

  def after_create(knowledge)
      Notification::Knowledge.create(
        :user => knowledge.checked_user,
        :knowledge => knowledge
      ).deliver
  end

  def after_save(knowledge)
    if knowledge.check_status_changed?
      Notification::KnowledgeCheck.create(
        :user => knowledge.creator,
        :knowledge => knowledge
      ).deliver    
    end
  end

  def after_destroy(knowledge)
    Notification::Knowledge.where(:knowledge_id => knowledge.id).destroy_all
  end
end
