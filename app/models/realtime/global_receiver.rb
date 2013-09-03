module Realtime
  class GlobalReceiver
    class << self
      # GlobalReceiver.to_realtime_receiver_id
      def to_realtime_receiver_id
        'global'
      end
    end
  end
end
