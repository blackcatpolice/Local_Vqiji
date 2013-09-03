# encoding: utf-8

require 'spec_helper'

describe Notification::Observers::ElearnTrainingUserObserver do
  
  it 'should not create NewElearnTraining after user added to unreleased training' do
    lambda {
      create :elearn_training_user, :training => create(:elearn_training, :released => false)
    }.should change(Notification::NewElearnTraining, :count).by(0)
  end
  
  it 'should create NewElearnTraining after user added to released training' do
    Notification::NewElearnTraining.any_instance.should_receive(:deliver).once
    lambda {
      create :elearn_training_user, :training => create(:elearn_training, :released => true)
    }.should change(Notification::NewElearnTraining, :count).by(1)
  end

  it 'should remove NewElearnTraining after user removed from released training' do
    training_user = create :elearn_training_user, :training => create(:elearn_training, :released => true)
    lambda {
      training_user.destroy
    }.should change(Notification::NewElearnTraining, :count).by(-1)
  end
end
