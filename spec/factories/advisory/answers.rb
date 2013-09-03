# encoding: utf-8

FactoryGirl.define do
  factory :advisory_answer, class: 'Answer' do
    sequence(:text) { |i| "question_text-#{i}" * 3 }
    association :question, factory: :advisory_question, strategy: :create
    expert { question.expert }
    replier { question.expert.user }
    # association :replier, factory: :user, strategy: :create
  end
end
