# encoding: utf-8
require 'spec_helper'

describe Followship do  
  context "user.followeds" do
    it "should increment counter by 1 after create" do
      new_followship = FactoryGirl.build :followship
      lambda {
        new_followship.save!
      }.should change(new_followship.user, :followeds_count).by(1)
    end
    
    it "should decrement counter by -1 after destroy" do
      saved_followship = FactoryGirl.create :followship
      lambda {
        saved_followship.destroy
      }.should change(saved_followship.user, :followeds_count).by(-1)
    end
  end
  
  context "followed.fans" do
    it "should increment counter by 1 after create" do
      new_followship = FactoryGirl.build :followship
      lambda {
        new_followship.save!
      }.should change(new_followship.followed, :fans_count).by(1)
    end
    
    it "should decrement counter by -1 after destroy" do
      saved_followship = FactoryGirl.create :followship
      lambda {
        saved_followship.destroy
      }.should change(saved_followship.followed, :fans_count).by(-1)
    end
    
    context "when follow_type == whisper" do
      it "should increment counter by 0 after create" do
        new_followship = FactoryGirl.build :followship, follow_type: Followship::FOLLOW_TYPE_WHISPER
        lambda {
          new_followship.save!
        }.should change(new_followship.followed, :fans_count).by(0)
      end
      
      it "should decrement counter by 0 after destroy" do
        saved_followship = FactoryGirl.create :followship, follow_type: Followship::FOLLOW_TYPE_WHISPER
        lambda {
          saved_followship.destroy
        }.should change(saved_followship.followed, :fans_count).by(0)
      end
    end
  end
end

describe Followship::Service do
  let(:i) { create :user }
  let(:other) { create :user }

  it 'follow/unfollow!/following? should works' do
    i.following?(other).should be_false

    i.follow(other)
    i.following?(other).should be_true

    i.unfollow!(other)
    i.following?(other).should be_false
  end
  
  it 'user should not follow themself' do
    lambda {
      i.follow(i)
    }.should raise_error
  end
end
