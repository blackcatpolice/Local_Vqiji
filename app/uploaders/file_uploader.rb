# encoding: utf-8
# 
# 文件上传器
#
class FileUploader < BaseUploader
  def store_dir
    "uploads/files/#{model.id}"
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
