# encoding: utf-8

# 专家
class QuestionType
  include Mongoid::Document
  include Mongoid::Timestamps
  
  STATUS_ENABLE = 1  #启用
  STATUS_DISABLE = 0  #禁用

  field :name , :type => String
  field :priority, :type => Integer, :default => 0 # 问题类型优先级，用于排序
  field :status, :type => Integer, :default => STATUS_DISABLE # 问题类型状态，0 禁用 1启用
  field :display, :type => Boolean, :default => false   # 显示提问人个人信息
  
  has_many :questions, :class_name => 'Question'
  has_many :experts, :class_name => 'Expert', :inverse_of => :expert_type
  
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_numericality_of :priority, :greater_than_or_equal_to => 0
  
  scope :enables, where(:status => STATUS_ENABLE) #启用的咨询类型
  scope :disables, where(:status => STATUS_DISABLE) #禁用的咨询类型
  
  def enable_experts
    experts.includes(:user).where(:status => Expert::STATUS_ENABLE)
  end
  
  def _modify status
    self.status = status || STATUS_ENABLE
    self.save
  end
  
  def week_popular
    self.questions.desc(:clicks, :created_at).limit(3)
  end
end
