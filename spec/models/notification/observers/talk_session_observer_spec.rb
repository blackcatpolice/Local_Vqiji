# encoding: utf-8

require 'spec_helper'

describe Notification::Observers::TalkSessionObserver do
  it '发送加入讨论组通知' do
    Notification::TalkGroupJoin.any_instance.should_receive(:deliver).once
    lambda {
      create(:talk_session)
    }.should change(Notification::TalkGroupJoin, :count).by(1)
  end

  it '删除加入讨论组通知' do
    talk_session = create(:talk_session)
    lambda {
      talk_session.destroy
    }.should change(Notification::TalkGroupJoin, :count).by(-1)
  end
end
