#coding: utf-8

class Knowledge::KnowledgeComment
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :content, :type => String
  field :check_status, :type => Integer
  field :comment_index, :type => Integer
  field :reply_count, :type => Integer
  field :is_reply, :type => Boolean, :default => false

  belongs_to :knowledge, :class_name => 'Knowledge::Knowledge'
  belongs_to :user, :class_name => 'User'
  belongs_to :reply_comment, :class_name => 'Knowledge::KnowledgeComment' 
  belongs_to :reply_to_user, :class_name => 'User'
  has_many :reply_comments, :class_name => 'Knowledge::KnowledgeComment', :inverse_of => 'reply_comment'

  before_save do |knowledge_comment|
    knowledge_comment.comment_index = knowledge.comments_count + 1
    knowledge.inc(:comments_count, 1)
  end

  scope :replyed, where(:is_reply => false)
end