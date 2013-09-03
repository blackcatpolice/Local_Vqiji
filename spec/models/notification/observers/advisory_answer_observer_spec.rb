# encoding: utf-8

require 'spec_helper'

describe Notification::Observers::AdvisoryAnswerObserver do
  it 'should create NewAdvisoryAnswer after answer created' do
    Notification::NewAdvisoryAnswer.any_instance.should_receive(:deliver).once
    lambda {
      create :advisory_answer
    }.should change(Notification::NewAdvisoryAnswer, :count).by(1)
  end

  it 'should remove NewAdvisoryAnswer after answer destroyed' do
    question = create :advisory_answer
    lambda {
      question.destroy
    }.should change(Notification::NewAdvisoryAnswer, :count).by(-1)
  end
end
