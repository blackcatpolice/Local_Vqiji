module Talk::UserExtends
  extend ActiveSupport::Concern

  included do |base|
    base.class_eval do
      has_many :talk_sessions, class_name: 'Talk::Session', inverse_of: :user
      has_many :talk_feeds, class_name: 'Talk::Feed', inverse_of: :user
      
      def talk
        @_talk ||= Talk::Service.new(self)
      end
    end
  end
end
