# encoding: utf-8

# 专家
class Expert
  include Mongoid::Document
  include Mongoid::Timestamps
  
  STATUS_ENABLE = 1
  STATUS_DISABLE = 0
  
  belongs_to :user, :class_name => 'User', :inverse_of => :expert
  belongs_to :expert_type, :class_name => 'QuestionType', :inverse_of => :experts
  field :status, :type => Integer, :default => STATUS_DISABLE #医生状态， 0 禁用 1启用
  field :post, :type => String #职称
  field :description, :type => String #描述
  
  #修改医生状态
  def _modify status
    self.status = status || STATUS_DISABLE
    self.save
  end

  validates_presence_of :user, :expert_type, :post
  validates_uniqueness_of :user_id
end
