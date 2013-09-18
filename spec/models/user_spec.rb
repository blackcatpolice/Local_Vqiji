# encoding: utf-8
require 'spec_helper'

describe User do
  before :each do
    DatabaseCleaner.clean
  end
  
  let(:admin) { FactoryGirl.create :user, email: 'admin@vqiji.com', name: '管理员' }
  
  it "should update name" do
    admin.update_attribute(:name, '习进平').should be_true
    admin.name.should == '习进平'
    admin.pinyin_name.should == 'xijinping'
    admin.pinyin_index.should == 'x'
  end
  
  it "should #send" do
    other = FactoryGirl.create(:user)
    tweet = nil
    
    lambda {
      tweet = admin.tweet(text: "测试微博")
    }.should change(Tweet, :count).by(1)
    
    tweet.should be_an_instance_of(Tweet)
    tweet.sender.should == admin
    tweet.text.should == "测试微博"
  end
  
  it "should #repost" do
    other = FactoryGirl.create(:user)
    tweet = admin.tweet(text: "测试微博")
    repost = nil

    lambda {
      repost = other.repost(tweet, "转发")
    }.should change(Tweet, :count).by(1)
    
    repost.should be_an_instance_of(Tweet)
    repost.text.should == "转发"
    repost.reforigin.should == tweet
  end
  
  it "should #destroy" do
    other = FactoryGirl.create(:user)
    tweet = create(:tweet, :sender => other)
    lambda {
      other.delete_tweet!(tweet)
    }.should change(Tweet, :count).by(-1)
  end

  it "should fuzzy search" do
    User.fuzzy_search_by_name('管').should include(admin)
    User.fuzzy_search_by_name('g').should include(admin)
    User.fuzzy_search_by_name('管理员').should include(admin)
    User.fuzzy_search_by_name('guanliyuan').should include(admin)
  end
end
