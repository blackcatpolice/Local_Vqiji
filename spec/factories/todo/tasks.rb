# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :todo_task, :class => 'Todo::Task' do
    sequence(:title) { |i| "todo-task-title-#{i}" }
    sequence(:details) { |i| "todo-task-details-#{i}" }
    
    association :creator, factory: :user, strategy: :create
    association :executor, factory: :user, strategy: :create
    executor_name { executor.name }
    
    start_date { Time.now + rand(30).days }
    end_date { start_date + rand(30).days }
  end
end
