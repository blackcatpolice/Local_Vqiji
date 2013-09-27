# encoding: utf-8
#
# 附件
class Attachment::Base
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  # 附件所属的实体,比如 微博/评论/私信/文章 等
  belongs_to :target, polymorphic: true
  belongs_to :uploader, :class_name => 'User', inverse_of: :attachments
  
  attr_readonly :target, :uploader

  index :target_id => 1
  index :uploader_id => 1
  
  scope :audios, -> { where(:_type.in => Attachment::Audio._types) }
  scope :pictures, -> { where(:_type.in => Attachment::Picture._types) }
  scope :network_disks, -> { where(:_type.in => Attachment::NetworkDisk._types) }
  
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
