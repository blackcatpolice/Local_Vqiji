#coding: utf-8
class Blog::Subject
  include Mongoid::Document
  # 回复时间
  include Mongoid::Timestamps::Created
  
  #专题标题
  field :title, type: String
     
  #专题详细
  field :detail,type: String #详细
  
  #阅读数
  field :read_count, type: Integer, default: 0
  
  #显示
  field :visible, type: Boolean, default: true
  
  belongs_to :type, :class_name => "Blog::Type", :foreign_key => "spheres"
  
  SOCIAL = 1
  
  INDUSTRY = 2
  
  LEFE = 3
  
  HEALTH = 4
  
  FINANCIAL = 5
  
  CHUNHANG = 6
  
  validates_presence_of :detail, :title, :spheres
  
  def self.spheres_subjects(sp)
  	where(:visible => true, :btype => 1, :spheres => sp).desc("created_at").limit(6)
  end
  
end
