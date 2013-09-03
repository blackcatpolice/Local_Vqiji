class Talk::Realtime::GroupReceiver
  class << self
    # GroupReceiver[Group]
    # GroupReceiver[String]
    def [](group)
      def group.to_realtime_receiver_id
        'talk/group/%s' % self.to_param
      end
      group
    end
  end
end
