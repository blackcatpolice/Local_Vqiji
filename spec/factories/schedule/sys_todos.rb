FactoryGirl.define do
  factory :schedule_sys_todo, :class => 'Schedule::SysTodo' do
    association :user, factory: :user, strategy: :create
    detail "This is schedule sys-todo detail."
    at "2013-06-05 12:00:01"
    scope 'todo'
    target_url 'http://www.google.com'
    target_id 0
  end
end
