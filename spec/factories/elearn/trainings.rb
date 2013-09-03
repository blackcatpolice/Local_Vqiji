# encoding: utf-8

FactoryGirl.define do
  factory :elearn_training, class: 'Training' do
    sequence(:name) { |i| "training_name-#{i}" }
    sequence(:summary) { |i| "training_summary-#{i}" * 3 }
    association :user, factory: :user, strategy: :create
    association :type, factory: :elearn_training_type, strategy: :create
  end
end
