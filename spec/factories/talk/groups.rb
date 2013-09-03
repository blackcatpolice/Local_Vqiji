# encoding: utf-8
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :talk_group, :class => 'Talk::Group' do
    topic "话题"
    association :creater, factory: :user, strategy: :create
    
    ignore do
      sessions_count 1
    end
    
    after :create do |group, evaluator|
      (evaluator.sessions_count - group.sessions.count).times do
        group.sessions.create!(user: create(:user))
      end
    end
  end
end
