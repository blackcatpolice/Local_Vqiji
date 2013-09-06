module Schedule::UserExtends
  extend ActiveSupport::Concern
  
  included do |base|
    base.class_eval do
      has_many :schedule_todos, class_name: 'Schedule::Todo', inverse_of: :user
      has_many :schedule_meetings, class_name: 'Schedule::Meeting', inverse_of: :user
    end
  end

  def schedule
    @_schedule ||= Schedule::Service.new(self)
  end
end
