# encoding: utf-8

FactoryGirl.define do
  factory :advisory_question_type, class: 'QuestionType' do
    sequence(:name) { |i| "question_type-#{i}" }
    status QuestionType::STATUS_ENABLE
  end
end
