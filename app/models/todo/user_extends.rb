module Todo::UserExtends
  extend ActiveSupport::Concern
  
  included do |base|
    base.class_eval do
      # 创建的任务
      has_many :created_todo_tasks, class_name: 'Todo::Task', inverse_of: :creater
      # 创被指定的任务
      has_many :todo_tasks, class_name: 'Todo::Task', inverse_of: :executor
    end
  end

  def todo
    @todo_service ||= Todo::Service.new(self)
  end
end
