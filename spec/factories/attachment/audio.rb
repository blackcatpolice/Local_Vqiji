# encoding: utf-8

FactoryGirl.define do
  factory :attachment_audio, :class => 'Attachment::Audio' do
    file { File.open(File.expand_path('../../assets/2-81s-audio.mp3', __FILE__)) }
  end
end
