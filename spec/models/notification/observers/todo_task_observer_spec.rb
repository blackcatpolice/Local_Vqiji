# encoding: utf-8

require 'spec_helper'

describe Notification::Observers::TodoTaskObserver do
  it 'should create NewTodoTask after TodoTask created' do
    Notification::NewTodoTask.any_instance.should_receive(:deliver).once
    lambda {
      create(:todo_task)
    }.should change(Notification::NewTodoTask, :count).by(1)
  end

  it 'should remove NewTodoTask after TodoTask destroyed' do
    task = create(:todo_task)
    lambda {
      task.destroy
    }.should change(Notification::NewTodoTask, :count).by(-1)
  end
end
