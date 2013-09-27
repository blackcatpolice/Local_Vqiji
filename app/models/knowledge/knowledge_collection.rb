#coding: utf-8

class Knowledge::Collection
  include Mongoid::Document
  
  field :excerpt_text, :type => String
  field :page_index, :type => Integer
  field :summaries,  :type => String

  belongs_to :knowledge, :class_name => 'Knowledge::Knowledge'
  belongs_to :knowledge_content, :class_name => 'Knowledge::KnowledgeContent'
  belongs_to :user, :class_name => 'User'
  
end
