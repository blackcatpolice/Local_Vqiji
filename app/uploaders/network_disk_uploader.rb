# encoding: utf-8
# 
# 文件上传器
#
class NetworkDiskUploader < BaseUploader
  def store_dir
    "uploads/disk/#{model.uploader_id}/#{model.id}"
  end

  def filename
    #original_filename
    "#{secure_token}.#{file.extension}" if original_filename.present?
  end
  
  protected
  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end
end
