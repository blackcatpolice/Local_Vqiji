# encoding: utf-8
#
# 语音附件
class Attachment::Audio < Attachment::Base
  mount_uploader :file, AudioUploader, mount_on: :filename
  field :duration, type: Float, default: 0.0
  
  validates_presence_of :file
  
  before_create do |audio|
    audio.duration = audio.file.duration
  end
  
  delegate :url, :to => :file

  def to_builder
    super do |base|
      base.(self, :duration)
      base.file_url file.url
    end
  end
end
