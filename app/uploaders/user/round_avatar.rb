# encoding: utf-8
# 更多 ImageMagick 信息：
#   http://www.imagemagick.org/Usage/thumbnails/

module User::RoundAvatar
  extend ActiveSupport::Concern

  included do
    begin
      require "mini_magick"
    rescue LoadError => e
      e.message << " (You may need to install the mini_magick gem)"
      raise e
    end
  end

  module ClassMethods
    def round_avatar options
      process :round_avatar => options
    end
  end
  
  BADGE_MASK_IMG = File.expand_path('../badge_mask.png', __FILE__)
  BADGE_OVERLAY_IMG = File.expand_path('../badge_overlay.png', __FILE__)
  
  def round_avatar(width, height, format = 'png')
    manipulate2! do |image|
      image.combine_options do |cmd|
        cmd.alpha 'set'
        cmd.gravity 'center'
        cmd.resize '80x80^'
        cmd.extent '90x90'
      end
      
      image = image.composite(MiniMagick::Image.open(BADGE_MASK_IMG), format) { |cmd| cmd.compose 'DstIn' }
      image = image.composite(MiniMagick::Image.open(BADGE_OVERLAY_IMG), format) { |cmd| cmd.compose 'Over' }
      
      image.resize "#{width}x#{height}"
      image
    end
  end
  
  def manipulate2!
    cache_stored_file! if !cached?
    image = ::MiniMagick::Image.open(current_path)
    image = yield(image)
    image.write(current_path)
    ::MiniMagick::Image.open(current_path)
  rescue ::MiniMagick::Error, ::MiniMagick::Invalid => e
    raise CarrierWave::ProcessingError, I18n.translate(:"errors.messages.mini_magick_processing_error", :e => e)
  end
  
end
