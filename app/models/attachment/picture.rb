# encoding: utf-8
#
# 图片附件
class Attachment::Picture < Attachment::Base
  alias :base_serializable_hash :serializable_hash
  mount_uploader :file, PictureUploader, mount_on: :filename, validates_integrity: true
  # 恢复被 carrierwave 修改了的 serializable_hash
  alias :serializable_hash :base_serializable_hash

  field :name

  validates :file, presence: true, if: ->(picture) { picture.file_integrity_error.blank? }
  validates :file, file_size: { maximum: 5.megabytes.to_i }, allow_blank: true
  
  delegate :url, :path, :to => :file

  def to_builder
    super do |base|
      base.(self, :name)
      base.file file.serializable_hash
    end
  end
end
