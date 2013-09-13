# encoding: utf-8
require 'spec_helper'
require 'carrierwave/test/matchers'

describe AudioUploader do
  include CarrierWave::Test::Matchers
  
  before do
    AudioUploader.enable_processing = true
    @uploader = AudioUploader.new
    @uploader.store!(File.open(File.expand_path('../../assets/2-81s-audio.mp3', __FILE__)))
  end

  after do
    AudioUploader.enable_processing = false
    @uploader.remove!
  end

  it "should have 2s duration" do
    @uploader.duration.should == 2.81
  end

  it "should make the audio readable only to the owner and not executable" do
    @uploader.should have_permissions(0666)
  end
end
