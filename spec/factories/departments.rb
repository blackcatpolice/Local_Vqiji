# encoding: utf-8

FactoryGirl.define do
  factory :department do    
    association :creator, factory: :user, strategy: :create
    sequence(:name) { |i| "department-name-#{i}" }
    level Department::TOP_LEVEL
    
    ignore do
      members_count 3
    end
    
    factory :first_level_department do
      level Department::FIRST_LEVEL
      association :sup, factory: :department, strategy: :create
    end
  
    factory :second_level_department do
      level Department::SECOND_LEVEL
      association :sup, factory: :first_level_department, strategy: :create
    end
    
    after(:create) do |department, evaluator|
      create_list :user, evaluator.members_count, department: department
    end
  end
end
