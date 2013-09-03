require 'spec_helper'

describe Schedule::Service do
  let(:service) { create(:user).schedule }

  describe '#todos' do
    it "should equals user.schedule_todos" do
      todo = create(:schedule_todo, user: service.user)
      service.todos.should == [todo]
    end
  end
  
  describe '#count_todos_by_month' do
    it "should works" do
      now = Time.parse('2013-6-10 15:00:00')

      create :schedule_todo, at: now - 1.month, user: service.user
      create :schedule_todo, at: now, user: service.user
      create :schedule_todo, at: now + 2.days, user: service.user
      create :schedule_todo, at: now + 1.month, user: service.user

      # sys-todo
      create :schedule_sys_todo, at: now - 1.month, user: service.user
      create :schedule_sys_todo, at: now, user: service.user
      create :schedule_sys_todo, at: now + 2.days, user: service.user
      create :schedule_sys_todo, at: now + 1.month, user: service.user

      count = service.count_todos_by_month(Date.parse('2013/6'))

      count[now.to_date].should == { count: 2, sys: 1 }
      count[(now + 2.days).to_date].should == { count: 2, sys: 1 }
    end
  end
end
