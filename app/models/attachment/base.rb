# encoding: utf-8
#
# 附件
class Attachment::Base
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  
  ENCRYPT_FILE_NAME = "encrypt.zip" 
  FILE_STATUS = 1
  FILE_STATUS_DELETE = 0
 
  # 附件所属的实体,比如 微博/评论/私信/文章 等
  belongs_to :target, polymorphic: true
  belongs_to :uploader, :class_name => 'User'

  index :target_id => 1
  index :uploader_id => 1
  
  def to_builder
    Jbuilder.new do |base|
      base.(self, :id, :_type, :uploader_id, :created_at)
      yield(base) if block_given?
    end
  end
  
  def serializable_hash(options = nil)
    to_builder.attributes!
  end
  
  class << self
    def find_by_id(id)
    	where(:_id => id).first
    end
    
    alias :get :find_by_id
  end
end
