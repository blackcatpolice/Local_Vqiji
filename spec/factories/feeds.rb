# encoding: utf-8

FactoryGirl.define do
  factory :feed do
    association :tweet, factory: :tweet, strategy: :create
    association :receiver, factory: :user, strategy: :create
  end
end
