class Notification::CountChangedTrigger < Realtime::Trigger
  attr_reader :new_count

  def initialize(new_count)
    @new_count = new_count
    super('notificationsCountChanged', [new_count])
  end
end
