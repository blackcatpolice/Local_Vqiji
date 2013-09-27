module Todo::UserExtends
  def self.included(base)
    base.class_eval do
      has_many :todo_tasks, class_name: 'Todo::Task', inverse_of: :executor, dependent: :destroy
      has_many :created_todo_tasks, class_name: 'Todo::Task', inverse_of: :creator, dependent: :destroy
      has_many :todo_logs, class_name: 'Todo::Log', inverse_of: :user, dependent: :destroy

      has_one :todo_counter, class_name: 'Todo::Counter', inverse_of: :user, dependent: :destroy
    end
  end

  def todo
    @todo_service ||= Todo::Service.new(self)
  end
end
