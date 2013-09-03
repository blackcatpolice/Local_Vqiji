# encoding: utf-8
#e-Learning
#制度类型

class RuleType

  include Mongoid::Document
  
  
  has_many :rules
  
  field :name,type:String #类型名称
  field :summary,type:String #类型简介
  field :count,:type => Integer, :default => 0 #包含的数量
  #
 # mount_uploader :image, TrainingUploader #培训类型主题图片
  
end
