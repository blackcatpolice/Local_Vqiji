# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :talk_replay, :class => 'Talk::Replay' do
    association :replay_to, factory: :user, strategy: :create
  end
end
