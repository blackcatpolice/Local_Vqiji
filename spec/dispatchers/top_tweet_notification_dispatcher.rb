# encoding: utf-8

require 'spec_helper'

describe Tweet::TopTweetNotificationDispatcher do
  it 'should dispatch feed' do
    feed = Gfeed.create!(:tweet => create(:tweet, :is_top => true), :group => create(:group), :is_top => true)
    Notification::TopTweet.should_receive(:dispatch).with(feed).once
    Tweet::TopTweetNotificationDispatcher.perform(feed.id)
  end
end
