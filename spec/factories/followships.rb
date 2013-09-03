# encoding: utf-8

FactoryGirl.define do
  factory :followship do
    association :user, factory: :user, strategy: :create
    association :followed, factory: :user, strategy: :create
  end
end
