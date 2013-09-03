# encoding: utf-8
# 工作组加入通知
#
class Notification::GroupJoin < Notification::Base
  belongs_to :group, class_name: 'Group'

  index(:user_id => 1, :group_id => 1)

  scope :to_user, ->(user) { where(:user_id => user.to_param) }
  scope :of_group, ->(group) { where(:group_id => group.to_param) }
  
  class << self
    def notify!(group_member)
      create!(:user => group_member.user, :group => group_member.group).deliver
    end
    
    def for(user, group)
      to_user(user).of_group(group)
    end
    
    def view_url(user = nil)
      url_helpers.mine_groups_path
    end
  end
end
