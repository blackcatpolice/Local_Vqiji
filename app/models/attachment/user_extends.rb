module Attachment::UserExtends
  def self.included(base)
    base.class_eval do
      has_many :attachments, class_name: 'Attachment::Base', inverse_of: :uploader
    end
  end
end
