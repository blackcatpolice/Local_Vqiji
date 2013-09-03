# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :schedule_todo, :class => 'Schedule::Todo' do
    association :user, factory: :user, strategy: :create
    detail "This is schedule todo detail."
    at "2013-06-05 12:00:01"
  end
end
