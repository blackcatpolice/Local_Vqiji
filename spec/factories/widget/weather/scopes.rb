# encoding: utf-8

FactoryGirl.define do
  factory :widget_weather_scope, class: 'Widget::Weather::Scope' do
    sequence(:name) { |i| "name-#{i}" }
    sequence(:code) { |i| "code-#{i}" }
  end
end
