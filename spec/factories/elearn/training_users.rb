# encoding: utf-8

FactoryGirl.define do
  factory :elearn_training_user, class: 'TrainingUser' do
    association :training, factory: :elearn_training, strategy: :create
    association :user, factory: :user, strategy: :create
  end
end
