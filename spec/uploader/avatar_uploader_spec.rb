# encoding: utf-8
require 'spec_helper'
require 'carrierwave/test/matchers'

describe User::AvatarUploader do
  include CarrierWave::Test::Matchers

  PICTURE_PATH = File.join(File.dirname(__FILE__), 'avatar.png')

  let(:user) { create :user }

  before :each do
    User::AvatarUploader.enable_processing = true
    @uploader = User::AvatarUploader.new(user, :avatar)
    @uploader.store!(File.open(File.expand_path('../../assets/avatar.png', __FILE__)))
  end
  
  after do
    User::AvatarUploader.enable_processing = false
    @uploader.remove!
  end
  
  context "the v84x84 version" do
    it "should scale down a landscape image to be exactly 84 by 84 pixels" do
      @uploader.v84x84.should have_dimensions(84, 84)
    end
  end
  
  context "the v80x80 version" do
    it "should scale down a landscape image to be exactly 80 by 80 pixels" do
      @uploader.v80x80.should have_dimensions(80, 80)
    end
  end
  
  context "the v50x50 version" do
    it "should scale down a landscape image to be exactly 50 by 50 pixels" do
      @uploader.v50x50.should have_dimensions(50, 50)
    end
  end
  
  context "the v40x40 version" do
    it "should scale down a landscape image to be exactly 40 by 40 pixels" do
      @uploader.v40x40.should have_dimensions(40, 40)
    end
  end
  
  context "the v30x30 version" do
    it "should scale down a landscape image to be exactly 30 by 30 pixels" do
      @uploader.v30x30.should have_dimensions(30, 30)
    end
  end

  it "should make the image readable only to the owner and not executable" do
    @uploader.should have_permissions(0666)
  end
end
