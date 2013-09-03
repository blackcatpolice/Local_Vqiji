# encoding: utf-8

require 'spec_helper'

describe Notification::Observers::GfeedObserver do
  it 'should enqueue TopTweetNotificationDispatcher after gfeed created' do
    Resque.should_receive(:enqueue).once
    group = create(:group, :members_count => 3)
    Gfeed.create!(:tweet => create(:tweet, :is_top => true), :group => group, :is_top => true)
  end

  it 'should remove TopTweet after gfeed destroyed' do
    group = create(:group, :members_count => 3)
    feed = Gfeed.create!(:tweet => create(:tweet, :is_top => true), :group => group, :is_top => true)
    Notification::TopTweet.dispatch(feed)
    lambda {
      feed.destroy
    }.should change(Notification::TopTweet, :count).by( -3 )
  end
end
