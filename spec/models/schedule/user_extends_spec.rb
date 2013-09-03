require 'spec_helper'

describe Schedule::UserExtends do
  it "define #schedule_todos" do
    create(:user).respond_to?(:schedule_todos).should be_true
  end

  it "define #schedule" do
    inst = create(:user)
    inst.respond_to?(:schedule).should be_true
    inst.schedule.should be_an_instance_of Schedule::Service
    inst.schedule.user.should == inst
  end
end
