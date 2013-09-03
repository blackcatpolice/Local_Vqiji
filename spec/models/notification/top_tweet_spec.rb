require 'spec_helper'

describe Notification::TopTweet do

  describe '#dispatch' do
    it 'should dispatch notifications to group members' do
      group = create(:group, :members_count => 3)
      feed = Gfeed.create!(:tweet => create(:tweet, :is_top => true), :group => group, :is_top => true)
      lambda {
        Notification::TopTweet.dispatch(feed)
      }.should change(Notification::TopTweet, :count).by( 3 )
    end
  end
end
