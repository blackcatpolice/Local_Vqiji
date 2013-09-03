# encoding: utf-8

require 'spec_helper'

describe Notification::Observers::ElearnTrainingObserver do
  it 'should create NewElearnTraining after Training released' do
    training = create :elearn_training
    # 设置 3 个成员
    create_list(:user, 3).each do |user|
      training.users.create(:user => user)
    end

    lambda {
      training.update_attribute(:released, true)
    }.should change(Notification::NewElearnTraining, :count).by(3)
  end
end
