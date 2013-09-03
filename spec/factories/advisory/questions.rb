# encoding: utf-8

FactoryGirl.define do
  factory :advisory_question, class: 'Question' do
    sequence(:title) { |i| "question_title-#{i}" }
    sequence(:text) { |i| "question_text-#{i}" * 3 }
    association :expert, factory: :advisory_expert, strategy: :create
    association :owner, factory: :user, strategy: :create
    # association :question_type, factory: :advisory_question_type, strategy: :create
    question_type { expert.expert_type }
  end
end
