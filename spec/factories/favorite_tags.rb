FactoryGirl.define do
  factory :favorite_tag, class: Favorite::Tag do
    association :user , factory: :user, strategy: :create
    sequence(:tag) { |i| "favorite-tag-#{i}" }
  end
end
