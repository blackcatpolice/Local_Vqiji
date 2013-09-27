# encoding: utf-8
# 新任务通知
#
class Notification::NewTodoTask < Notification::Base
  belongs_to :task, class_name: 'Todo::Task'
  
  index :user_id => 1, :task_id => 1
  
  class << self
    def view_url(user = nil)
      url_helpers.received_todo_tasks_path
    end
  end
end
