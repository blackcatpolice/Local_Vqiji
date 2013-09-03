# encoding: utf-8
# 任务相关的处理程序
class Todo::Service
	include Todo::Finder

	attr_reader :user
	attr_accessor :pass
	attr_accessor :msgs

	def initialize(user)
		@user = user
		@msgs = Hash.new
	end
	
  #= task =
  
  def tasks
    user.todo_tasks
  end
  
  def created_tasks
    user.created_todo_tasks
  end

	def new_task(opts = Hash.new)
		Todo::Task.new(opts)
	end

	def new_task_by_sup_id(sup_id)
		Todo::Task.new(:sup_id=>sup_id)
	end

	def new_log(opts = Hash.new)
		Todo::Log.new(opts)
	end

	def create_task(opts, file_id = nil, picture_id = nil)
		task = self.new_task(opts)
		task.executor = self.find_user_by_name(task.executor_name)
		unless task.sup_id.blank?
  		sup = self.find_task_by_id task.sup_id
  		if sup.schedule == Todo::Task::SCHEDULE_COMPLETED || sup.schedule == Todo::Task::SCHEDULE_CONFIRM
  		  self.msgs[:sup] = "任务待确认中或已解决，无法新建自任务！"
        return task 
  		end
		end
		unless task.start_date <= task.end_date
      self.msgs[:date] = "任务结束时间必须大于开始时间"
      return task 
    end
		unless task.executor
			self.msgs[:executor] = "任务处理人不存在"
			return task 
		end
		task.set_file file_id
		task.set_picture picture_id
		task.creator = self.user
		#task.logs.build(:user => self.user,:task => task,:msg => "新建任务")
		self.pass = task.save
		#
		creator_count = self.find_or_create_count_by_user(task.creator)
		creator_count.inc(:create, 1)
		creator_count.inc(:create_now, 1)
		#
		executor_count = self.find_or_create_count_by_user(task.executor)
		executor_count.inc(:execute, 1)
		executor_count.inc(:execute_now, 1)
		#

		self.msgs[:notice] = "任务创建成功!"
		return task
	end

	def confirm_task(task)
		unless task.value == 100
			self.msgs[:error] = "任务进度没有达到100%"
			return
		end
		log = task.logs.build(:user => self.user,:task=>task,:msg =>"确认完成任务!",:value => task.value, :old_value => task.value)
		task.schedule = Todo::Task::SCHEDULE_COMPLETED
		
		task.completed_at = Time.now
		self.pass = task.save
	end

	def update_task(task,opts)
		task.update_attributes(opts)
		task.logs.build(:user => self.user,:task => task,:msg => "编辑任务")
		self.pass = task.save
	end

	def destroy_task(task)
		return unless task.creator == self.user
		task.destroy
		creator_count = self.find_or_create_count_by_user(task.creator)
		creator_count.inc(:create,-1) if creator_count.create > 0
		#
		executor_count = self.find_or_create_count_by_user(task.executor)
		executor_count.inc(:execute,-1) if creator_count.create > 0
	end

  #= count =
	def current_user_count
		find_or_create_count_by_user(self.user)
	end

	def create_count user
		return Todo::Count.create(:user => user)
	end
	
	def find_or_create_count_by_user user
		count = self.find_count_by_user(user)
		count = self.create_count(user) unless count
		return count
	end
	
	#= log =
	def create_log(task, opts, todo_task = nil, file_id = nil, picture_id = nil)
	  log = task.logs.build(:user => self.user,:task=>task,:msg=>opts[:msg], :value=>opts[:value], :old_value => task.value, :old_task_schedule=>task.schedule)
	  log.set_file(file_id)
	  log.set_picture(picture_id)
    task.value = log.value
    
	  if task.creator == self.user
	    task.schedule = Todo::Task::SCHEDULE_COMPLETED if task.value == 100
	    task.confirm_at = Time.now if task.schedule == Todo::Task::SCHEDULE_COMPLETED
      unless todo_task.blank?
        task.end_date = todo_task[:end_date]
        task.level = todo_task[:level]
      end
	  end
	  self.pass = task.save
	  return log
	end
end
