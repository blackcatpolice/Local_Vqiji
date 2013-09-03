# encoding: utf-8
#
# 网盘
class Attachment::NetworkDisk < Attachment::Base
  UPLOAD_TYPE_HISTORY = 'HISTORY'   #病历
  UPLOAD_TYPE_NETWORK_DISK = 'NETWORK_DISK'  #网盘

  mount_uploader :file, NetworkDiskUploader, mount_on: :filename
  field :name, type: String # 文件名
  field :size, type: Integer, default: 0 # size in byte
  field :status, type: Integer, default: FILE_STATUS
  field :encrypt, type: Boolean, default: false #默认不加密
  
  #validates :file, presence: true, file_size: { maximum: 5.megabytes.to_i }
  
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
