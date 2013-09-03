require 'spec_helper'

describe Schedule::SysTodo do
  it { should validate_presence_of(:scope) }

  it "should store in the collection same with Schedule::Todo" do
    sys_todo = create :schedule_sys_todo
    Schedule::Todo.where(:id => sys_todo.id).first == sys_todo
  end
end
