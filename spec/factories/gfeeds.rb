# encoding: utf-8

FactoryGirl.define do
  factory :gfeed do
    association :tweet, factory: :tweet, strategy: :create
    association :group, factory: :group, strategy: :create
    
    is_top { tweet.is_top }
  end
end
