# encoding: utf-8

FactoryGirl.define do
  factory :elearn_training_type, class: 'TrainingType' do
    sequence(:name) { |i| "training_name-#{i}" }
    sequence(:summary) { |i| "training_summary-#{i}" }
  end
end
