# encoding: utf-8

FactoryGirl.define do
  factory :group do
    association :creator, factory: :user, strategy: :create
    
    sequence(:name) { |i| "group-name-#{i}" }
    sequence(:notice) { |i| "group-notice-#{i}" }
    sequence(:summary) { |i| "group-summary-#{i}" }
    
    ignore do
      members_count 0
    end
    
    after(:create) do |group, evaluator|
      if evaluator.members_count > 0
        group.joins( create_list(:user, evaluator.members_count - group.members.count) )
      end
    end
  end
end
