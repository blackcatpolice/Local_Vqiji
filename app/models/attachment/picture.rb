# encoding: utf-8
#
# 图片附件
class Attachment::Picture < Attachment::Base
  alias :base_serializable_hash :serializable_hash
  mount_uploader :file, PictureUploader, mount_on: :filename, validates_integrity: true
  # 恢复被 carrierwave 修改了的 serializable_hash
  alias :serializable_hash :base_serializable_hash

  # FIXED：在 presence 和 integrity 验证不能同时存在
  field :name, type: String # 文件名
  field :size, type: Integer, default: 0 # size in byte
  validates :file, presence: true, if: ->(picture) { picture.file_integrity_error.blank? }
  validates :file, file_size: { maximum: 5.megabytes.to_i }, allow_blank: true
  
  delegate :url, :to => :file
  
  def serializable_hash(options=nil)
    super(except: [:file])
  end

  def to_builder
    super do |base|
      base.file file.serializable_hash
    end
  end
end
