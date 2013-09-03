#coding: utf-8

#制度

class Rule
	include Mongoid::Document
   # 发送时间
  include Mongoid::Timestamps
  
  include Mongoid::Taggable
  
 
 	belongs_to :rtype, class_name: 'RuleType'
  
  field :title
  
  field :content
  
  field :creater_id, type: Integer
  
  field :read, type: Boolean, default: false
  
  field :visible, type: Boolean, default: false
  
  mount_uploader :picture, RuleUploader
  
	validates :creater_id, :title, :content, :presence => true
  
  def creater
   
   begin
  	User.find(creater_id)
   rescue
   	puts 'noting'
   end
   	
  end
  
  

end
