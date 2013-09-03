# encoding: utf-8

FactoryGirl.define do
  factory :city do
    sequence(:country) { |i| "country-#{i}" }
    sequence(:province) { |i| "province-#{i}" }
    sequence(:name) { |i| "city-#{i}" }
    
    factory :city_in_china do
      country '天艹'
    end
  end
end
