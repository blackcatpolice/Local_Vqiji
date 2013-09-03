require 'spec_helper'

describe Talk::Message::User do
  let(:user) { create :user }
  let(:group) { create :talk_group, creater: user }
  let(:message) { build :user_talk_message, group: group, sender: user }

  describe "#dispatch!" do
    let(:user2) { create :user }

    before :each do
      group.add_member(user2)
      message.save!
    end
    
    it '为成员创建 Feed' do
      lambda {
        message.dispatch!
      }.should change(Talk::Feed, :count).by(2)
    end
    
    it '修改 unread_count += 1' do
      @session2 = group.session_for(user2)
      lambda {
        message.dispatch!
        @session2.reload
      }.should change(@session2, :unread_count).by(1)
    end
    
    it '分发消息给发送人，并标记为已读' do
      message.dispatch!
      feed = message.feed_for(user)
      feed.is_read.should be_true
    end
  end
end
