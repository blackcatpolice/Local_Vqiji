# encoding: utf-8

FactoryGirl.define do
  factory :advisory_expert, class: 'Expert' do
    association :user, factory: :user, strategy: :create
    association :expert_type, factory: :advisory_question_type, strategy: :create
    sequence(:post) { |i| "advisory_expert_post-#{i}" }
    status Expert::STATUS_ENABLE
  end
end
