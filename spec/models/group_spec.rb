require 'spec_helper'

describe Group do
  let(:user) { create :user }
  let(:group) { create :group }

  it 'Manage members' do
    group.has?(user).should be_false
    group.has_admin?(user).should be_false
    group.admin_users.should == [group.creator]
    group.admins_count.should == 1
    group.get_member(user).should be_nil
    group.member_user_ids.should == [group.creator.to_param]
    
    group.join(user, true)
    group.has?(user).should be_true
    group.has_admin?(user).should be_true
    group.admin_users.should == [group.creator, user]
    group.admins_count.should == 2
    group.get_member(user).should == group.members.where(:user_id => user.to_param).first
    group.member_user_ids.should == [group.creator.to_param, user.to_param]
  end
  
  it '#find_by_id' do
    Group.find_by_id(group.id).should == group
  end
  
  it '#get_group_ids_by_user_id' do
    Group.get_group_ids_by_user_id(group.creator.id).should == [group.to_param]
  end
end
