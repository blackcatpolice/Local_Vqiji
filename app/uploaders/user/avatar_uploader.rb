# encoding: utf-8
#
require File.expand_path('../round_avatar', __FILE__)

class User::AvatarUploader < BaseUploader
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick
  include User::RoundAvatar

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    # For Rails 3.1+ asset pipeline compatibility:
    asset_path("defaults/user/" + [version_name, "#{model.gender == User::GENDER_FEMALE ? 'girl_' : ''}avatar.png"].compact.join('_'))
    # "defaults/user/" + [version_name, 'avatar.png'].compact.join('_')
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    #@name ||= "avatar.#{file.extension}" if original_filename.present?
    'avatar.png' if original_filename.present?
  end
  
  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/users/#{model.id}"
  end
    
  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(png jpg)
  end

  process :convert => 'png'
  
  # 存为 png 格式的目的是保留透明通道
  def cache_name
    File.join(cache_id, "#{full_original_filename}.png") if cache_id and original_filename
  end
  
  version 'v84x84' do
    process :round_avatar => [84, 84, 'png']
  end

  version 'v80x80' do
    process :round_avatar => [80, 80, 'png']
  end

  version 'v50x50' do
    process :round_avatar => [50, 50, 'png']
  end

  version 'v40x40' do
    process :round_avatar => [40, 40, 'png']
  end

  version 'v30x30' do
    process :round_avatar => [30, 30, 'png']
  end
  
end
