# encoding: utf-8
require 'spec_helper'
require 'carrierwave/test/matchers'

describe User::FileUploader do
  include CarrierWave::Test::Matchers
  before :each do
    FileUploader.enable_processing = true
    @uploader = FileUploader.new(create(:tweet))
    @uploader.store!(File.open(File.expand_path('../../assets/clock.jpg', __FILE__)))
  end
  
  after do
    FileUploader.enable_processing = false
    @uploader.remove!
  end

  it "should make the file readable only to the owner and not executable" do
    @uploader.should have_permissions(0666)
  end
end
