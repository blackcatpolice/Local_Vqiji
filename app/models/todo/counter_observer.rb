module Todo::CounterObserver
  extend ActiveSupport::Concern

  included do
    after_create do |task|
      # 创建的（&待完成）任务 +1
		  task.creator.todo.counter.instance_eval do
		    increment_created_tasks_count!
		    increment_created_tasks_uncompleted_count!
		  end

      # 收到的（&待完成）任务 +1
		  task.executor.todo.counter.instance_eval do
		    increment_received_tasks_count!
		    increment_received_tasks_uncompleted_count!
		  end
    end
    
    after_destroy do |task|
	    # 创建人
		  task.creator.todo.counter.instance_eval do
        # 创建的任务 -1
		    decrement_created_tasks_count!
		    if task.finished?
		      if timeout?
           # 超时完成 +1
           decrement_created_tasks_finished_timeout_count!
         else
           # 按时完成 + 1
           decrement_created_tasks_finished_ontime_count!
		      end
		    else
		      if completed?
	          # 确认中 -1
		        decrement_created_tasks_confirming_count!
		      else
	          # 待完成 -1
		        decrement_created_tasks_uncompleted_count!
		      end
		    end
		  end
		      
      # 负责人
	    task.executor.todo.counter.instance_eval do
        # 创建的任务 -1
	      decrement_received_tasks_count!
	      if task.finished?
	        if timeout?
           # 超时完成 +1
           decrement_received_tasks_finished_timeout_count!
         else
           # 按时完成 + 1
           decrement_received_tasks_finished_ontime_count!
	        end
	      else
	        if completed?
	          # 确认中 -1
	          decrement_received_tasks_confirming_count!
	        else
	          # 待完成 -1
	          decrement_received_tasks_uncompleted_count!
	        end
	      end
		  end
    end

    after_completed do |task|
	    # 创建人
	    task.creator.todo.counter.instance_eval do
        # 待完成任务 -1
        decrement_created_tasks_uncompleted_count!
        # 待确认 +1
        increment_created_tasks_confirming_count!
      end
     
      # 负责人
	    task.executor.todo.counter.instance_eval do
        # 待完成任务 -1
        decrement_received_tasks_uncompleted_count!
        # 待确认 +1
        increment_received_tasks_confirming_count!
      end
    end
    
    after_uncompleted do |task|
      # 创建人
      task.creator.todo.counter.instance_eval do
        # 待完成任务 +1
        increment_created_tasks_uncompleted_count!
        # 待确认 -1
        decrement_created_tasks_confirming_count!
      end

      # 负责人
      task.executor.todo.counter.instance_eval do
        # 待完成任务 +1
        increment_received_tasks_uncompleted_count!
        # 待确认 -1
        decrement_received_tasks_confirming_count!
      end
    end

    after_finished do |task|
      # 创建人
      task.creator.todo.counter.instance_eval do
        # 待确认 -1
        decrement_created_tasks_confirming_count!
        if task.timeout?
         # 超时完成 +1
         increment_created_tasks_finished_timeout_count!
        else
         # 按时完成 + 1
         increment_created_tasks_finished_ontime_count!
        end
      end

      # 负责人
      task.executor.todo.counter.instance_eval do
        # 待确认 -1
        decrement_received_tasks_confirming_count!
        if task.timeout?
         # 超时完成 +1
         increment_received_tasks_finished_timeout_count!
        else
         # 按时完成 + 1
         increment_received_tasks_finished_ontime_count!
        end
      end
    end
    
  end # /included
end
