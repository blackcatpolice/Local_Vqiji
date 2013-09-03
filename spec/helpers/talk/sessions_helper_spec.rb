# encoding: utf-8

require 'spec_helper'

# Specs in this file have access to a helper object that includes
describe Talk::SessionsHelper do
  shared_context :context do
    before(:all) do
      @user = create :user
    end
    
    before(:each) { sign_in @user }
  end
  
  describe "#talk_session_title" do
    include_context :context

    before(:all) do
      @user1 = FactoryGirl.create :user
      @user2 = FactoryGirl.create :user
    end

    it "私信会话返回对方名字" do
      group = create :talk_group, creater: @user, p2p: true
      group.add_member(@user1)
      session = group.session_for(@user)
      helper.talk_session_title(session.reload).should == "#{ @user1.name }"
    end
  end
  
  describe "#talk_session_subtitle" do
    include_context :context

    before(:all) do
      @user1 = create :user
      
      @group = create :talk_group, creater: @user
      @session = @group.session_for(@user)
    end
    
    it "当会话为私信组时返回对方的部门和工作信息" do
      group = create :talk_group, creater: @user, p2p: true
      other = create(:user, department: create(:department, name: 'department'), job: 'job')
      group.add_member(other)
      helper.talk_session_subtitle(group.session_for(@user)).should == "department : job"
    end
  end
  
  describe "#talk_session_avatar_url" do
    include_context :context
    
    it "私信会话显示对方头像" do
      other = FactoryGirl.create :user
      group = FactoryGirl.create :talk_group, creater: @user, p2p: true
      session = group.session_for(@user)
      group.add_member(other)
      helper.talk_session_avatar_url(session.reload).should == other.avatar.v50x50.url
    end
  
    it "讨论组会话显示 'duoren.png'" do
      group = FactoryGirl.create :talk_group, creater: @user, :sessions_count => 3
      session = group.session_for(@user)
      helper.talk_session_avatar_url(session.reload).should == helper.image_path('duoren.png')
    end
  end
end
