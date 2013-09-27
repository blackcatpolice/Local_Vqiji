module Todo::ScheduleObserver
  extend ActiveSupport::Concern

  included do     
    after_create do |task|
      __create_sys_todo!(task)
    end
    
    # 当最后完成时间修改后，修改待办事项中的任务
    around_update do |task, &block|
      (block.call(self) and return) unless (task.end_at_changed?)

      block.call(self)
      
      systodo = Schedule::SysTodo.todo_tasks.where(:target_id => task.id, :scope => Schedule::SysTodo::SCOPE_TODO_TASK).first
      if systodo
        if systodo.at != task.end_at
          systodo.update_attribute(:at, task.end_at)
        end
      else
        __create_sys_todo!(task)
      end
    end
  
    after_destroy do |task|
      Schedule::SysTodo.where(:target_id => task.id, :scope => Schedule::SysTodo::SCOPE_TODO_TASK).destroy_all
    end

    def __create_sys_todo!(task)
      Schedule::SysTodo.create(
        :detail => task.title,
        :at => task.end_at,
        :user => task.executor,
        :target_id => task.id,
        :target_url => "/todo/tasks/#{task.to_param}", #Rails.application.routes.todo_task_path(task), 
        :scope => Schedule::SysTodo::SCOPE_TODO_TASK
      )
    end
  end
end
