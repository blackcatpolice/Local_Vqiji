# 通知
class Notification::Base
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  store_in :collection => 'notifications'
  
  # fields
  belongs_to :user, class_name: 'User', inverse_of: :notifications # 接收人

  # validations
  validates_presence_of :user

  # indexes
  index :user_id => 1
  index :user_id => 1, :created_at => -1

  def deliver
    user.notification.trigger_count_changed! if persisted?
  end
  
  class << self
    def view_url(user = nil)
      '#'
    end

    delegate :url_helpers, :to => 'Rails.application.routes'
  end
end
