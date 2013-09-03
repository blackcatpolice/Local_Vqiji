# encoding: utf-8

class Notification::Observers::TodoTaskObserver < Mongoid::Observer
  observe 'todo/task'
  
  def after_create(task)
    if (user = task.executor)
      Notification::NewTodoTask.create(
        :user => user,
        :task => task
      ).deliver
    end
  end
  
  def after_destroy(task)
    if (user = task.executor)
      if ( Notification::NewTodoTask.where(
        :user_id => user.id,
        :task_id => task.id
      ).destroy_all > 0 )
        user.notification.trigger_count_changed!
      end
    end
  end
end
