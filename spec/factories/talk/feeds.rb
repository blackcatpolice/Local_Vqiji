# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :talk_feed, :class => 'Talk::Feed' do
    association :message, factory: :user_talk_message, strategy: :create
    association :receiver, factory: :user, strategy: :create
    is_read false
    
    group_id { message.group_id }
    
    after(:build) { |feed| feed.group.add_member(feed.receiver) }
  end
end
