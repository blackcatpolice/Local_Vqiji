# use by handler
# 任务相关的查询程序

module Todo::Finder
	## query methods => about task
	def find_tasks (opts = nil)
		Todo::Task.all
	end

	def find_task_by_id(id)
		Todo::Task.find_by_id(id)
	end

	def find_tasks_by_executor_and_creator user
		Todo::Task.where("$or"=>[ {'executor_id' => user.id} ,{'creator_id' => user.id} ])
	end

	def find_tasks_by_executor executor
		Todo::Task.find_by_executor_id(executor.id)
	end

	def find_unfinished_tasks_by executor
		Todo::Task.executor_unfinished_scope(executor.id)
	end

	def find_tasks_by_creator creator
		Todo::Task.find_by_creator_id(creator.id)
	end

	def will_timeout_tasks executor
		Todo::Task.find_will_timeout(executor.id).asc(:end_date)
	end
	
	def timeout_tasks executor
		Todo::Task.executor_unfinished_scope(executor.id).timeout_scope
	end

	def will_finish_tasks creator
		 Todo::Task.find_by_creator_id(creator.id).where(:value=>100).confirm_scope.desc(:confirm_at)
	end

	## query methods => about log
	def find_logs_by_task task
		task.logs
	end

	## query methods => about count
	def find_count_by_id id
		Todo::Count.find_by_id(id)
	end

	def find_count_by_user user
		Todo::Count.find_by_user_id(user.id)
	end

	def find_counts
		Todo::Count.all
	end

	def find_user_by_id id
    User.where(:_id => id).first
  end

  def find_user_by_name name
  	User.where(:name => name).first
  end
  
  
  def find_users_by_name name
    reg = /#{name}/i
    users = User.where("$or" => [{ name: reg}, { pinyin_name: reg}])
    
    _users = []
    users.only(:name).collect do |u|
      _users << u.name
    end
    
    return _users
  end
end
