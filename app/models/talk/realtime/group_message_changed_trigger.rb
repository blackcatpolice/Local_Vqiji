# encoding: utf-8
#
# 及时通知
#
class Talk::Realtime::GroupMessageChangedTrigger < Realtime::Trigger
  attr_reader :group, :trigger

  def initialize(group, trigger)
    @group = group
    @trigger = trigger
    super('talkGroupMessageChanged', [@group.id, { sender_id: @trigger.to_param }])
  end
  
  def throw!
    throw_to!(Talk::Realtime::GroupReceiver[@group])
  end
  
  class << self
    def notify(group, trigger)
      new(group, trigger).throw!
    end
  end
end
