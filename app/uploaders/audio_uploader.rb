# encoding: utf-8
require 'carriverwave/ffmpeg'

# 音频文件 uploader
class AudioUploader < BaseUploader
  include CarrierWave::MimeTypes
  #include CarrierWave::FFMPEG

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    'uploads/audios/'
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
   "#{secure_token}.#{file.extension}" if original_filename.present?
  end

  #process :set_content_type
  
  # flv 格式
  #version :flv do
  #  def flv_filename(name)
  #    "#{ name.chomp(File.extname(name)) }.flv" if name.present?
  #  end
  #  
  #  def filename
  #    flv_filename(super)
  #  end
  #  
  #  def full_original_filename
  #    flv_filename(original_filename)
  #  end
  #  
  #  def full_filename(for_file = filename)
  #    flv_filename(for_file)
  #  end
  #  
  #  # ffmpeg -i test.spx -ab 16 -ar 22050 -ac 1 -f flv test.flv
  #  process :transcode_flv
  #end

  def extension_white_list
    %w(mp3)
  end
  
  # 获取音频长度
  def duration
    return 0 unless current_path

    ::FFMPEG::Movie.new(current_path).duration
  end

  protected
  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end
end
