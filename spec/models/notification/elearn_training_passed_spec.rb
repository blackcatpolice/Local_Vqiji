require 'spec_helper'

describe Notification::ElearnTrainingPassed do
  it '通过 #notify! 发送通知' do
    training_user = create(:elearn_training_user)
    lambda {
      Notification::ElearnTrainingPassed.notify!(training_user)
    }.should change(Notification::ElearnTrainingPassed, :count).by( 1 )
  end
end
