# encoding: utf-8

FactoryGirl.define do
  factory :tweet do
    text "这是一条长长的微博~这是一条长长的微博~这是一条长长的微博~这是一条长长的微博~这是一条长长的微博~这是一条长长的微博~"
    association :sender, factory: :user, strategy: :create
    
    factory :repost_tweet do
      association :reforigin, factory: :tweet, strategy: :create
    end
    
    factory :top_tweet do
      is_top true
    end
  end
end
