# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :todo_count, :class => 'Todo::Count' do
    association :user, factory: :user, strategy: :create
  end
  
end
