# encoding: utf-8

# 语音附件
class Attachment::Audio < Attachment::Base
  mount_uploader :file, AudioUploader, mount_on: :filename
  field :duration, type: Float, default: 0.0
  
  attr_readonly :filename, :duration

  validates_presence_of :file
  
  before_create do |audio|
    audio.duration = audio.file.duration
  end
  
  delegate :url, :path, :to => :file
  
  def name
    filename
  end
  
  def to_builder
    super do |base|
      base.(self, :duration, :url)
    end
  end
end
