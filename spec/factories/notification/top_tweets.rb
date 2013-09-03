# encoding: utf-8

FactoryGirl.define do
  factory :top_tweet_notification, class: 'Notification::TopTweet' do
    association :feed, factory: :gfeed, strategy: :create
  end
end
