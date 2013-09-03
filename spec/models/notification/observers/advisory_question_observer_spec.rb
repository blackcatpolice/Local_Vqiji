# encoding: utf-8

require 'spec_helper'

describe Notification::Observers::AdvisoryQuestionObserver do
  it 'should create NewAdvisoryQuestion after question created'do
    Notification::NewAdvisoryQuestion.any_instance.should_receive(:deliver).once
    lambda {
      create :advisory_question
    }.should change(Notification::NewAdvisoryQuestion, :count).by(1)
  end

  it 'should remove NewAdvisoryQuestion after question destroyed' do
    question = create :advisory_question
    lambda {
      question.destroy
    }.should change(Notification::NewAdvisoryQuestion, :count).by(-1)
  end

  it 'should create AdvisoryQuestionSolved after question solved' do
    question = create :advisory_question
    Notification::AdvisoryQuestionSolved.any_instance.should_receive(:deliver).once
    lambda {
      question.update_attribute(:solved, true)
    }.should change(Notification::AdvisoryQuestionSolved, :count).by(1)
  end

  it 'should remove AdvisoryQuestionSolved after question destroyed' do
    question = create :advisory_question
    question.update_attribute(:solved, true)
    lambda {
      question.destroy
    }.should change(Notification::AdvisoryQuestionSolved, :count).by(-1)
  end
end
