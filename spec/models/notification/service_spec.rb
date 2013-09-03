require 'spec_helper'

describe Notification::Service do
  let(:user) { create :user }
  let(:service) { user.notification }
  
  it '#count' do
    service.count.should == 0
    notification = Notification::Base.create!(:user => user)
    service.count.should == 1
    service.count(Notification::Fan).should == 0 # has 0 Notification::Fan
    notification.destroy
    service.count.should == 0
  end

  it '#map' do
    notification = Notification::Base.create!(:user => user)
    notification2 = Notification::Base.create!(:user => user)
    user.reload.notifications.should have(2).items
    service.map.should == {
      Notification::Base => [
        notification,
        notification2
      ]
    }
  end

  it '#reset!' do
    user.reload.notifications.should have(0).items
    notification = Notification::Base.create!(:user => user)
    user.reload.notifications.should have(1).items
    user.notification.reset!(Notification::Fan) # can't reset by Notification::Fan
    user.reload.notifications.should have(1).items
    user.notification.reset!(Notification::Base)
    user.reload.notifications.should have(0).items
  end

  it '#delete!' do
    user.reload.notifications.should have(0).items
    notification = Notification::Base.create!(:user => user)
    user.reload.notifications.should have(1).items
    user.notification.delete!(notification)
    user.reload.notifications.should have(0).items
  end
end
