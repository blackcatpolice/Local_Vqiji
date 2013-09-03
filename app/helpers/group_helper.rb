module GroupHelper
  def admin_of_any_group?(user = current_user)
    user.group_members.where(:is_admin => true).exists?
  end
  
  def admin_of_group?(group, user = current_user)
    user.group_members.where(:group_id => group.to_param, :is_admin => true).exists?
  end
end
