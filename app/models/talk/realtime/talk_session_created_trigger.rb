# encoding: utf-8
#
class Talk::Realtime::TalkSessionCreatedTrigger < Realtime::Trigger
  attr_reader :session

  def initialize(session)
    @session = session
    super('talkSessionCreated', [session.id])
  end
  
  def throw!
    throw_to!(Realtime::UserReceiver[session.user_id])
  end
  
  class << self
    def notify(session)
      new(session).throw!
    end
  end
end
