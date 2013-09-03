# encoding: utf-8

FactoryGirl.define do
  factory :user_talk_message, :class => 'Talk::Message::User' do
    association :group, factory: :talk_group, strategy: :create
    sender { group.creater }
    text "这是一条秘密的私信"
  end
  
  factory :user_join_talk_message, :class => 'Talk::Message::Sys' do
    association :group, factory: :talk_group, strategy: :create
    actor { create :user }
    type Talk::Message::Sys::TYPE_USER_JOIN
  end
  
  factory :user_quit_talk_message, :class => 'Talk::Message::Sys' do
    association :group, factory: :talk_group, strategy: :create
    actor { create :user }
    type Talk::Message::Sys::TYPE_USER_QUIT
  end
end
