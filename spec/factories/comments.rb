# encoding: utf-8

FactoryGirl.define do
  factory :comment do
    text '这是一条评论，评论，评论'
    sender
    association :tweet, factory: :tweet, strategy: :create
    factory :reply_comment do
      refcomment { FactoryGirl.create(:comment, tweet: tweet) }
    end
  end
end
