def dump(json, task_node)
  task = task_node[:task]
  json.(task, :id, :title)
  json.expanded task_node[:expanded] || false
  json.classes task_node[:classes]
  json.url todo_task_path(task)
  json.creator  task.creator.name
  json.executor task.executor.name
  json.children_count task.subs_count
  json.children task_node[:children] do |child_path|
    dump(json, child_path)
  end
end

def root_node(task)
  children_paths = task.subs.collect do |child|
    {
      task: child,
      children: []
    }
  end
  
  current = {
    task: task,
    children: children_paths,
    expanded: true,
    classes: 'current'
  }
  
  path = current
  
  sup = task.sup
  while(sup) do
    path = {
      task: sup,
      children: [ path ]
    }
    sup = sup.sup
  end
  
  path
end

dump(json, root_node(@task))
