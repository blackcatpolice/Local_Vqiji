# encoding: utf-8

require 'spec_helper'

describe Notification::Observers::FollowshipObserver do
  it 'should create Fan after follow' do
    Notification::Fan.any_instance.should_receive(:deliver).once
    lambda {
      create(:user).follow(create(:user))
    }.should change(Notification::Fan, :count).by(1)
  end

  it 'should remove Fan after followship destroyed(unfollow)' do
    followship = create(:user).follow(create(:user))
    lambda {
      followship.destroy
    }.should change(Notification::Fan, :count).by(-1)
  end
end
