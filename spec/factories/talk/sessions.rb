# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :talk_session, :class => 'Talk::Session' do
    association :user, factory: :user, strategy: :create
    association :group, factory: :talk_group, strategy: :create
  end
end
