module Todo::TasksHelper

  # 本地化最后
  def format_task_end_at(end_at)
    seconds = (Time.now - end_at)
    days = (seconds.abs / (24 * 60 * 60)).ceil
    if days >= 1
      return (seconds > 0) ? "已经超时#{days}天" : "还有#{days.abs}天到期"
    end

    hours = (seconds.abs / (60 * 60)).ceil
    if hours >= 1
      return (seconds > 0) ? "已经超时#{hours}小时" : "还有#{hours.abs}小时到期"
    end
    
    minutes = (seconds.abs / 60.0).ceil
    (seconds > 0) ? "已经超时#{minutes}分钟" : "还有#{minutes.abs}分钟到期"
  end
  
  def todo_task_status(task)
    if task.finished?
      '已完成'
    else
      if task.completed?
        '待确认'
      else
        '待完成'
      end
    end
  end
  
  def todo_task_priority(task)
    t "todo.task.priority.#{ task.priority }"
  end
  
end
