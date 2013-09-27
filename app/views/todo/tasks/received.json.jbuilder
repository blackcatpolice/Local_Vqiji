json.array! @tasks do |task|
  json.(task, :id, :title, :priority, :start_at, :end_at, :progress)
  json.will_timeout task.will_timeout?
  json.formated_end_at format_task_end_at(task.end_at)
end
