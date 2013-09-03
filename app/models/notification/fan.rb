# encoding: utf-8
# 关注通知

class Notification::Fan < Notification::Base
  belongs_to :followship, :class_name => 'Followship'
  
  index :user_id => 1, :followship_id => 1
  
  class << self
    def view_url(user = nil)
      "/users/#{user.to_param}/fans"
    end
  end
end
