# encoding: utf-8
#
# 文件附件
class Attachment::File < Attachment::Base
  alias :base_serializable_hash :serializable_hash
  mount_uploader :file, FileUploader, mount_on: :filename
  # 恢复被 carrierwave 修改了的 serializable_hash
  alias :serializable_hash :base_serializable_hash

  field :name, type: String # 文件名
  field :size, type: Integer, default: 0 # size in byte
  field :encrypt, type: Boolean, default: false #默认不加密
  field :status, type: Integer, default: FILE_STATUS
  
  validates :file, presence: true, file_size: { maximum: 5.megabytes.to_i, allow_blank: true }
  
  before_create do |attachment|
    attachment.size = attachment.file.size
  end
  
  delegate :url, :to => :file
  
  def to_builder
    super do |base|
      base.(self, :name, :size)
      base.url file.url
    end
  end
end
