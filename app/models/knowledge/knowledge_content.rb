#coding: utf-8

class Knowledge::KnowledgeContent
  include Mongoid::Document
  
  field :text, :type => String
  field :page_index, :type => Integer
  belongs_to :knowledge, :class_name => 'Knowledge::Knowledge'
  
end