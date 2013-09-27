#coding: utf-8

class Knowledge::Content
  include Mongoid::Document
  
  field :content, :type => String
  field :page_index, :type => Integer
  belongs_to :knowledge, :class_name => 'Knowledge::Knowledge', :inverse_of => 'knowledge_contents'

  before_save do |knowledge_content|
    knowledge_content.page_index = knowledge.contents_count + 1
    knowledge.inc(:contents_count, 1)
  end
  
end
