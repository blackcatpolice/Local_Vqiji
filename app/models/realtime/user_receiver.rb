module Realtime
  class UserReceiver
    class << self
      # UserReceiver[User]
      # UserReceiver[String]
      def [](user)
        def user.to_realtime_receiver_id
          'private/%s' % self.to_param
        end
        user
      end
    end
  end
end
