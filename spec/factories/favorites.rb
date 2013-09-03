# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :favorite do
    association :user , factory: :user, strategy: :create
    association :tweet , factory: :tweet, strategy: :create
  end
end
