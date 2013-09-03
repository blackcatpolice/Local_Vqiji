module Notification::UserExtends
  def self.included(base)
    base.class_eval do
      has_many :notifications, class_name: 'Notification::Base', inverse_of: :user

      def notification
        @_notification ||= Notification::Service.new(self)
      end
    end
  end
end
