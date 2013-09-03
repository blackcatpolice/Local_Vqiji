# encoding: utf-8

require 'spec_helper'

describe Notification::Observers::GroupMemberObserver do
  
  it '用户被加入工作组后给用户发送通知' do
    group_member = create(:group_member)
    lambda {
      group_member = create(:group_member)
    }.should change(Notification::GroupJoin, :count).by( 1 )
  end
  
  it '不发送加入工作组通知给创建人' do
    group = create :group
    lambda {
      group = create :group
    }.should change(Notification::GroupJoin, :count).by( 0 )
  end
  
  it '用户被移除工作组后删除加入工作组通知' do
    group_member = create(:group_member)
    lambda {
      group_member.destroy
    }.should change(Notification::GroupJoin, :count).by( -1 )
  end
  
  it '当用户退出组后删除所有重要微博通知' do
    group_member = create :group_member
    gfeed = create :gfeed, group: group_member.group
    top_tweet_notifictation = create :top_tweet_notification, feed: gfeed, user: group_member.user

    lambda {
      group_member.destroy
    }.should change(Notification::TopTweet, :count).by(-1)
  end
end
