# encoding: utf-8
require 'spec_helper'

describe Talk::Group do

  describe "#create" do
    it '自动添加创建人为成员' do
      group = create :talk_group
      group.sessions[0].user.should == group.creater
    end
  end
  
  describe "#add_member" do
    it '为讨论组添加成员' do
      group = create :talk_group, sessions_count: 3
      other = create :user
      
      group.add_member(other)
      group.has_member?(other).should be_true
    end
    
    it '不能为私信会话组添加成员' do
      group = create :talk_group, p2p: true, sessions_count: 2
      other = create :user
      
      lambda {
        group.add_member(other)
      }.should raise_error(Talk::Error)
    end
  end
  
  describe "#remove_member!" do
    it '删除讨论组' do
      group = create :talk_group, sessions_count: 3
      other = group.sessions.first.user
      
      group.remove_member!(other)
      group.has_member?(other).should be_false
    end
    
    it '如果是私信会话组,通过 delete 删除' do
      group = create :talk_group, p2p: true, sessions_count: 2
      other = group.sessions.first.user
      other_session = group.session_for(other)
      other_session.deleted?.should be_false
      
      group.remove_member!(other)
      
      other_session.reload
      other_session.deleted?.should be_true
    end
  end
  
  it "#between 返回 user 和 receiver 之间的私信会话组" do
    u1 = create :user
    u2 = create :user
    
    Talk::Group.between(u1, u2).should be_nil
    group = nil
    
    lambda {
      group = Talk::Group.p2p_find_or_create_by(u1, u2)
    }.should change(Talk::Group, :count).by(1)
    
    Talk::Group.between(u1, u2).should == group
    Talk::Group.between(u2, u1).should == group

    group.sessions.each do |session|
      session.delete
    end
    Talk::Group.between(u1, u2).should == group
  end
  
  describe "#p2p_find_or_create_by" do
    let(:u1) { create :user }
    let(:u2) { create :user }
    
    it '没有私信会话时创建新私信会话' do
      lambda {
        group = Talk::Group.p2p_find_or_create_by(u1, u2)      
        group.should be_an_instance_of(Talk::Group)
        group.p2p.should be_true
      }.should change(Talk::Group, :count).by(1)
    end
    
    it '存在私信会话时返回存在的会话' do
      Talk::Group.p2p_find_or_create_by(u1, u2).should_not be_nil

      lambda {
        Talk::Group.p2p_find_or_create_by(u1, u2).should_not be_nil
      }.should_not change(Talk::Group, :count)
    end
  end
  
  it '#restore_sessions! 重置所有会话的 deleted 状态' do
    group = create :talk_group, :p2p => true, :sessions_count => 2

    group.sessions.each do |session|
      session.delete
    end
    
    group.restore_sessions!
    
    group.reload.sessions.each do |session|
      session.deleted?.should be_false
    end
  end

  describe '#send_message' do
    let(:user) { create :user }
    let(:group) { create :talk_group, :creater => user, :p2p => true }
    
    it '创建消息' do
      lambda {
        group.send_message(user, "发信息")
      }.should change(Talk::Message::User, :count).by(1)
    end
    
    it '调用 #restore_sessions! 如果是私信会话组' do
      group.should_receive(:restore_sessions!).once
      group.send_message(user, "发信息")
    end
    
    it '调用 dispatch!' do
      Talk::Message::User.any_instance.should_receive(:dispatch!).once
      group.send_message(user, "发信息")
    end
    
    it '调用 realtime_notifiy_message_changed' do
      group.should_receive(:realtime_notifiy_message_changed).once.with(user)
      group.send_message(user, "发信息")
    end
  end
  
  describe '#realtime_notifiy_message_changed' do
    let(:user) { create :user }
    let(:group) { create :talk_group }

    it '通过 Talk::Realtime::GroupMessageChangedTrigger#notify 发送通知' do
      Talk::Realtime::GroupMessageChangedTrigger.should_receive(:notify).once.with(group, user)
      group.realtime_notifiy_message_changed(user)
    end
  end
end
