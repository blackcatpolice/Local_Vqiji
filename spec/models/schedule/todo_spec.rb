require 'spec_helper'

describe Schedule::Todo do
  it { should validate_presence_of(:detail) }
  it { should validate_presence_of(:at) }
  it { should validate_presence_of(:user) }

  it "should order by at ASC" do
    user = create :user
    now = Time.now
    todo2 = create :schedule_todo, at: now + 2.days, user: user
    todo1 = create :schedule_todo, at: now + 1.days, user: user
    
    user.schedule_todos.should == [todo1, todo2]
  end
  
  it "#in_range should works" do
    user = create :user
    
    now = Time.parse('2013-6-5 15:00:00')
    todo1 = create :schedule_todo, at: now + 1.days, user: user
    todo2 = create :schedule_todo, at: now + 2.days, user: user
    todo3 = create :schedule_todo, at: now + 3.days, user: user
    todo4 = create :schedule_todo, at: now + 4.days, user: user
    
    user.schedule_todos.in_range(now + 2.days, now + 4.days).should == [todo2, todo3, todo4]
  end
end
