# encoding: utf-8

# 培训类型
class TrainingType
  include Mongoid::Document
  
  field :name, type: String #培训类型名称
  field :summary, type: String #培训类型简介
  
  has_many :trainings, class_name: 'Training' #包含培训
  field :trainings_count, :type => Integer, :default => 0 #包含的培训数量
  # field :posts_count, :type => Integer, :default => 0

  mount_uploader :image, TrainingUploader #培训类型主题图片
end
