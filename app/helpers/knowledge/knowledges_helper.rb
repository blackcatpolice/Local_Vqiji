# encoding: utf-8
module Knowledge::KnowledgesHelper

  def knowledge_type_image_tag(image_name)
    raw image_tag "knowledges/#{image_name}"
  end

  def knowledge_public_name(knowledge)
    if knowledge.published?
      knowledge.is_public? ? "公开发布" : "小组发布"
    else
      Knowledge::Knowledge::CHECK_STATUS[knowledge.check_status]
    end
  end

  def can_delete_reply_comment?(reply_comment)
    reply_comment.knowledge.checked_user == current_user ||
    reply_comment.knowledge.creator == current_user ||
    reply_comment.user == current_user
  end

end
