# encoding: utf-8
module Knowledge::KnowledgesHelper
  def knowledge_type_image_tag image_name
    raw image_tag "knowledges/#{image_name}"
  end

  def knowledge_public_name(knowledge)
    if knowledge.published?
      knowledge.is_public? ? "公开发布" : "小组发布"
    else
      Knowledge::Knowledge::CHECK_STATUS[knowledge.check_status]
    end
  end
end
