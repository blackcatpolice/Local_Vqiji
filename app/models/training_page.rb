# encoding: utf-8

# 培训页
class TrainingPage
  include Mongoid::Document

  belongs_to :training, :class_name => 'Training' #
  has_many :tests, :class_name => 'TrainingTest' #培训测试
  belongs_to :next, :class_name => 'TrainingPage' #
  
  field :number,:type => Integer # 培训页编号
  field :title,:type => String # 标题
  field :context,:type => String # 内容
  field :next_id,:type => String #下一页的ID
  field :tests_count,:type => Integer, :default => 0 #测试题目数量
  
  mount_uploader :image, TrainingUploader #主题图片

  # 默认排序
  default_scope desc(:created_at)

  def set_next
    pages = TrainingPage.where(:training_id=>self.training_id).desc("number") # 5,4,3,2,1
    next_id = nil
    pages.each do |page|
      page.update_attributes(:next_id=>next_id)
      next_id = page.id
    end
  end

  before_save do |page|
    page.context = page.context.gsub(/<[^><]*script[^><]*>/i,'') if page.context_changed?
  end

  after_create do |page|
    self.training.inc(:pages_count,1) if self.training
    self.set_next
  end

  after_destroy do |page|
    self.set_next
    self.training.inc(:pages_count,-1) if self.training && self.training.pages_count > 0
  end
end
