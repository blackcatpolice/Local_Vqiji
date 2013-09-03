# encoding: utf-8
module KnowledgesHelper
  def knowledge_type_image_tag image_name
    raw image_tag "knowledges/#{image_name}"
  end
end
