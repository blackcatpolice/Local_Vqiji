# encoding: utf-8

FactoryGirl.define do
  factory :user, aliases: [:sender] do
    sequence(:email) { |i| "user-#{i}@vqiji.com" }
    password "12345678"
    password_confirmation "12345678"
    sequence(:name) { |i| "name-#{i}"}
    sequence(:job_no) { |i| '%d' % i }
    check_at Time.now.utc

    trait :unchecked do
      check_at nil
    end
    
    factory :unchecked_user, traits: [:unchecked]
  end
end
