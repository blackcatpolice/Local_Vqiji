#coding: utf-8

class Knowledge
  include Mongoid::Document
  include Mongoid::Timestamps
  include Handler::PinyinTitle
  
  KNOWLEDGE_STATUS_PUBLISH = 1 #已发布
  KNOWLEDGE_STATUS_DRAFT = 0  #草稿
  
  #已发布的知识
  scope :published, where(:status => KNOWLEDGE_STATUS_PUBLISH)
  
  field :title, :type => String
  field :text, :type => String
  field :clicks, :type => Integer, default: 0
  field :status, :type => Integer, default: KNOWLEDGE_STATUS_DRAFT
  field :public, :type => Boolean, default: true

  belongs_to :creator, :class_name => 'User'
  belongs_to :knowledge_type, :class_name => 'KnowledgeType'
  belongs_to :group, :class_name => 'Group'
  
  index :title => 1
  index :knowledge_type_id => 1
  index :creator_id => 1
  
  before_save do
    self.text = self.text.gsub(/<[^><]*script[^><]*>/i,'') if self.text_changed?
  end
end
