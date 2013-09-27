json.array! @task.subs do |child|
  json.(child, :id, :title)
  json.url todo_task_path(child)
  json.creator  child.creator.name
  json.executor child.executor.name
  json.children_count child.subs_count
end
