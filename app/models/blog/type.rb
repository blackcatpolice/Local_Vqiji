#coding: utf-8
#专题类型的图片管理
class Blog::Type
	include Mongoid::Document
#   # 发送时间
  include Mongoid::Timestamps
  
  field :name
  
  field :isview, type: Boolean, default: false
  
  field :position, type: Integer, default: 0
  
  mount_uploader :body_image, PictureUploader
  
  mount_uploader :header_image, PictureUploader
  
  has_many "subjects", 
  					:class_name => "Blog::Subject", 
  					:dependent => :destroy,
  					:foreign_key => "spheres"
end
