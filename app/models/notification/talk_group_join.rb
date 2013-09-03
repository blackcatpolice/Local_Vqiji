# encoding: utf-8
# 讨论组加入通知
#
class Notification::TalkGroupJoin < Notification::Base
  belongs_to :group, class_name: 'Talk::Group'

  scope :to_user, ->(user) { where(:user_id => user.to_param) }
  scope :of_group, ->(group) { where(:group_id => group.to_param) }
  
  index(:user_id => 1, :group_id => 1)
  
  class << self
    def notify!(session)
      create!(:user => session.user, :group => session.group).deliver
    end
    
    def for(user, group)
      to_user(user).of_group(group)
    end
    
    def view_url(user = nil)
      url_helpers.talk_path
    end
  end
end
