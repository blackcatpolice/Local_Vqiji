# encoding: utf-8
require 'spec_helper'

describe Tweet do
  let(:user) { FactoryGirl.create(:user) }

  it 'should maintain reftweet/refchain/reposts_count' do
    tweet = create :tweet
    tweet.reforigin.should == nil
    tweet.refchain.should be_blank
    tweet.reftweet.should == nil
    tweet.reposts_count.should == 0
    tweet.reposts.should be_blank
    
    repost = create(:tweet, :reforigin => tweet)
    tweet.reload
    
    repost.reforigin.should == tweet
    repost.refchain.should == [tweet.id]
    repost.reftweet.should == tweet
    tweet.reposts_count.should == 1
    #tweet.reposts.should == [repost]
    
    repost2 = create :tweet, reforigin: repost
    repost.reload
    tweet.reload
    
    repost2.reforigin.should == repost
    repost2.refchain.should == [repost.id, tweet.id]
    repost2.reftweet.should == tweet
    repost.reposts_count.should == 1
    #repost.reposts.should == [repost2]
    tweet.reposts_count.should == 2
    #tweet.reposts.should == [repost, repost2]

    repost2.destroy
    repost.reload
    tweet.reload

    repost = create :tweet, reforigin: tweet
    repost.reposts_count.should == 0
    repost.reposts.should be_blank
    tweet.reposts_count.should == 1
    #tweet.reposts.should == [repost]
  end

  it "#comment" do
    tweet = FactoryGirl.create(:tweet)
    user = FactoryGirl.create(:user)
    tweet.comments_count.should == 0
    tweet.comments.should be_blank

    comment = tweet.comment(user, "第一条评论")
    tweet.comments.should == [comment]

    comment.text.should == "第一条评论"
    comment.sender.should == user
  end

  it '重要微博不分发给粉丝' do
    tweet = create :tweet, :is_top => true
    tweet.to_fans?.should be_false
  end

  it '_to_fans != true 的微博不能分发给粉丝' do
    tweet = create :tweet, :_to_fans => false
    tweet.to_fans?.should be_false
  end
    
  it '重要微博不能转发' do
    tweet = create :tweet, :is_top => true
    tweet.repostable?.should be_false
  end
    
  it '_to_fans != true 的微博不能转发' do
    tweet = create :tweet, :_to_fans => false
    tweet.repostable?.should be_false
  end
  
  describe "#dispatch" do
    it "should dispatch to fans." do
      _users = create_list :user, 3

      _users[0].follow(user)
      _users[1].follow(user, follow_type: Followship::FOLLOW_TYPE_WHISPER)
      _users[2].follow(user, follow_type: Followship::FOLLOW_TYPE_PARTICULAR)

      tweet = create :tweet, sender: user
      
      lambda {
        tweet.dispatch
      }.should change(Feed, :count).by(3)

      _users[0].feeds.where(:tweet_id => tweet.id).should have(1).items
      _users[1].feeds.where(:tweet_id => tweet.id).should have(1).items
      _users[2].feeds.where(:tweet_id => tweet.id).should have(1).items
    end

    it "should dispatch to groups." do
      _groups = create_list :group, 3
      
      _groups[0].join(user)
      _groups[1].join(user)
      _groups[2].join(user, true)

      tweet = create :tweet, sender: user, group_ids: [_groups[0].id, _groups[2].id]
      
      lambda {
        tweet.dispatch
      }.should change(Gfeed, :count).by(2)

      _groups[0].feeds.where(:tweet_id => tweet.id).should have(1).items
      _groups[1].feeds.where(:tweet_id => tweet.id).should have(0).items
      _groups[2].feeds.where(:tweet_id => tweet.id).should have(1).items
    end
    
    it "should not dispatch to groups which user not join in." do
      group = create :group
      tweet = create :tweet, sender: user, group_ids: [group.to_param]
      group.feeds.where(:tweet_id => tweet.id).should have(0).items
    end
  end
end
