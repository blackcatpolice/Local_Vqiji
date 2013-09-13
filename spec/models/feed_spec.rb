# encoding: utf-8

require 'spec_helper'

describe Feed do

  describe '#read!' do
    it 'should set read_at' do
      feed = create :feed
      feed.read!
      feed.read_at.should_not be_nil
      feed.readed?.should be_true
    end
  
    it 'should increment tweet\'readers count' do
      feed = create :feed
      feed.tweet.readers_count.should == 0
      feed.read!
      feed.tweet.reload.readers_count.should == 1
    end
  end

  describe '#unread!' do
    it 'should set read_at = nil' do
      feed = create :feed
      feed.read!
      
      feed.unread!
      feed.read_at.should be_nil
      feed.readed?.should be_false
    end
  
    it 'should decrement tweet\'readers count' do
      feed = create :feed
      feed.read!
      
      feed.tweet.reload.readers_count.should == 1
      feed.unread!
      feed.tweet.reload.readers_count.should == 0
    end
  end

end
