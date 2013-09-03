# encoding: utf-8

class BaseUploader < CarrierWave::Uploader::Base
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper

  storage :file
  
  delegate :delete, :basename, :size, :to => :file
  
  # def sanitize_regexp
   # CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:].-+]/
     # CarrierWave::SanitizedFile.sanitize_regexp
   #   CarrierWave::SanitizedFile.sanitize_regexp =/[*]/ # /[^a-zA-Z0-9\.\-\+_]/ #/[^[:word:].-+]/
  # end
end
