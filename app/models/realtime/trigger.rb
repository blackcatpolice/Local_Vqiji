# encoding: utf-8
#
# 触发器
#
class Realtime::Trigger
  attr_reader :callback
  attr_reader :params
  
  def initialize(callback, params = nil)
    @callback = callback
    @params = params
  end
  
  def to_trigger_param
    {
      callback: callback,
      params: params
    }.to_json
  end
  
  def throw_to!(receiver)
    $redis.publish(channel_to(receiver), to_trigger_param)
  end
  
  def throw_to_global!
    throw_to!(Realtime::GlobalReceiver)
  end
  
  class << self
    def trigger(callback, params, receiver)
      Realtime::Trigger.new(callback, params).throw_to!(receiver)
    end
  end
  
  private
  
  def channel_to(receiver)
    'realtime/%s/trigger' % receiver.to_realtime_receiver_id
  end
end
