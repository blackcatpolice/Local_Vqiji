# encoding: utf-8

FactoryGirl.define do
  factory :group_member, class: 'GroupMember' do
    association :user, factory: :user, strategy: :create
    association :group, factory: :group, strategy: :create
    
    trait :is_admin do
      is_admin true
    end
    
    factory :group_admin_member, :traits => [:is_admin]
  end
end
