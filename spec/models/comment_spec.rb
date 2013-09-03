# encoding: utf-8

require 'spec_helper'

describe Comment do
  it 'should fill cache atribute before save' do
    tweet = create :tweet
    comment = create :comment, tweet: tweet

    comment.tweeter.should == tweet.sender
    comment.rtext.should_not be_nil
  end

  it 'should able to replay' do
    comment = create :comment
    commenter = create :user

    reply = comment.reply(commenter, '回复评论', comment)
    reply.should be_an_instance_of(Comment)
    reply.reply?.should be_true
    reply.sender.should == commenter
  end
  
  it 'should fill cache atribute before save replay' do
    comment = create :comment
    reply = create :comment, refcomment: comment
    
    reply.tweet.should == comment.tweet
    reply.tweeter.should == comment.tweeter
    reply.refsender.should == comment.sender
  end
end
