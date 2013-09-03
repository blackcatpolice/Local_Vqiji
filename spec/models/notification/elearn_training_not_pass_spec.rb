require 'spec_helper'

describe Notification::ElearnTrainingNotPass do
  it '通过 #notify! 发送通知' do
    training_user = create(:elearn_training_user)
    lambda {
      Notification::ElearnTrainingNotPass.notify!(training_user)
    }.should change(Notification::ElearnTrainingNotPass, :count).by( 1 )
  end
end
