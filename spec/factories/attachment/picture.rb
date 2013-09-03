# encoding: utf-8

FactoryGirl.define do
  factory :attachment_picture, :class => 'Attachment::Picture' do
    file { File.open(File.expand_path('../../assets/clock.jpg', __FILE__)) }
  end
end
