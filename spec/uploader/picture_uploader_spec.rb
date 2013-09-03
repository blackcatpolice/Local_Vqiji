# encoding: utf-8
require 'spec_helper'
require 'carrierwave/test/matchers'

describe User::AvatarUploader do
  include CarrierWave::Test::Matchers
  before :each do
    PictureUploader.enable_processing = true
    @uploader = PictureUploader.new
    @uploader.store!(File.open(File.expand_path('../../assets/clock.jpg', __FILE__)))
  end
  
  after do
    PictureUploader.enable_processing = false
    @uploader.remove!
  end
  
  context "the thumb version" do
    it "should scale down a landscape image to be exactly 120 by 120 pixels" do
      @uploader.thumb.should be_no_wider_than(120)
      @uploader.thumb.should be_no_taller_than(120)
    end
  end

  it "should make the image readable only to the owner and not executable" do
    @uploader.should have_permissions(0666)
  end
end
