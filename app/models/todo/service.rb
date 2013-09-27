# encoding: utf-8
# 任务相关的处理程序
class Todo::Service
	attr_reader :user

	def initialize(user)
		@user = user
	end
	
  def tasks
		Todo::Task.where("$or"=>[ {'executor_id' => @user.id}, {'creator_id' => @user.id} ])
  end
  
  def logs
    @user.todo_logs
  end
  
  def received_tasks
    @user.todo_tasks
  end
  
  def created_tasks
    @user.created_todo_tasks
  end

	def counter
		@user.todo_counter || Todo::Counter.create(:user => @user)
	end
  
  # 更新任务进度
  def update_progress!(task, progress, info, opts={})
    # raise Todo::Error, '你没有权限修改该任务进度！' unless (task.executor?(@user) || task.creator?(@use))
    raise Todo::Error, '任务已经完成，不能再更新进度！' if task.finished?
    task.logs.create! do |log|
      log.old_progress = task.progress
      task.update_attribute(:progress, progress.to_i)
      log.progress = task.progress
      
      log.user = @user
      log.info = info
      log.set_picture(opts[:picture]) if opts[:picture]
      log.set_file(opts[:file]) if opts[:file]
    end
  end
  
  # 确认完成！
  def confirm!(task)
    return if task.confirmed?
    task.update_attribute(:confirmed_at, Time.now.utc)
  end
end
