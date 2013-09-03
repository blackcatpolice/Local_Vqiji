require 'spec_helper'

describe Talk::Service do
  it 'user#talk' do
    user = create :user
    user.talk.should be_an_instance_of(Talk::Service)
    user.talk.user.should == user
  end

  it "#to" do
    session = FactoryGirl.create :talk_session
    session.user.talk.to(session, "信息").should be_an_instance_of(Talk::Feed)
    lambda {
      create(:user).talk_to(session, '信息')
    }.should raise_error
  end

  describe '#create_group' do
    it "如果成员只有两人, 通过 Talk::Group#p2p_find_or_create_by 查找/创建私信会话组" do
      user = create(:user)
      other = create(:user)
      Talk::Group.should_receive(:p2p_find_or_create_by).with(user, other).once
      group = user.talk.create_group(other)
    end
    
    it "如果成员多于两人, 创建讨论会话组" do
      users = create_list(:user, 3)
      group = nil
      lambda {
        group = create(:user).talk.create_group(users, "I'm Topic")
      }.should change(Talk::Group, :count).by(1)
      group.sessions.should have(4).items
      group.topic.should == "I'm Topic"
      group.should be_an_instance_of(Talk::Group)
    end
  end

  it '#add_members' do
    group = create :talk_group
    lambda {
      group.creater.talk.add_members(group, create_list(:user, 3))
    }.should change(Talk::Session, :count).by(3)
  end
  
  #it '加入会话后发送通知消息' do
  #  group = create :talk_group
  #  lambda {
  #    group.creater.talk.add_members(group, create(:user))
  #  }.should change(Talk::Message::Sys, :count).by(1)
  #end

  describe "#delete_member!" do
    it '不能删除创建人' do
      group = create :talk_group
      lambda {
        group.creater.talk.delete_member!(group, group.creater)
      }.should raise_error(Talk::Error)
    end
    
    it '非创建人不能删除成员' do
      group = create(:talk_group, :sessions_count => 3)
      members = (group.sessions.collect(&:user) - [ group.creater ])
      lambda {
        members[0].talk.delete_member!(group, members[1])
      }.should raise_error(Talk::Error)
    end
    
    it '删除成员' do
      group = create(:talk_group, :sessions_count => 3)
      members = (group.sessions.collect(&:user) - [ group.creater ])
      lambda {
        group.creater.talk.delete_member!(group, members[0])
      }.should change(Talk::Session, :count).by(-1)
    end
  end

  it "#quit!" do
    group = create :talk_group
    lambda {
      group.creater.talk.quit!(group)
    }.should change(Talk::Session, :count).by(-1)
  end
  
  it '退出会话发送通知消息' do
    group = create :talk_group
    lambda {
      group.creater.talk.quit!(group)
    }.should change(Talk::Message::Sys, :count).by(1)
  end
end
