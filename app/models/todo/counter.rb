class Todo::Counter
	include Mongoid::Document
	
  @@refreshable_fields = {}
	belongs_to :user, :class_name => 'User', inverse_of: :todo_counter, index: true
  
  # 定义 counter 字段
  def self.counter_field(field_name, opts = {}, &block)
    field_name_as = opts.delete(:as) || field_name

    define_args = { :type => Integer, :default => 0 }
    define_args.merge(opts) if opts
    
    field field_name, define_args
    alias_method(field_name_as, field_name)

    # increment_xxx!
    define_method "increment_#{field_name_as}!" do
      inc(field_name, 1)
    end
    
    # decrement_xxx!
    define_method "decrement_#{field_name_as}!" do
      inc(field_name, -1)
    end
    
    # refresh_xxx!
    if block_given?
      define_method "refresh_#{field_name_as}!" do
        count = block.call(self)
        update_attribute(field_name, count)
        count
      end

      @@refreshable_fields[field_name] = block
    end
  end # /counter_field
	
	# 分配的任务 ( ct => created tasks )
	counter_field :ct_count, as: :created_tasks_count do |counter|
	  counter.user.todo.created_tasks.count
	end
	
	# 未完成的任务（排队中或进行中的任务）
	counter_field :ct_uncompleted, as: :created_tasks_uncompleted_count do |counter|
	  counter.user.todo.created_tasks.uncompleted.count
	end
	
	# 待确认任务数
	counter_field :ct_confirming, as: :created_tasks_confirming_count do |counter|
	  counter.user.todo.created_tasks.completed.unconfirmed.count
	end
	
	# 按时完成任务
	counter_field :ct_finished_ontime, as: :created_tasks_finished_ontime_count do |counter|
	  counter.user.todo.created_tasks.completed._untimeout.count
	end

	# 超时完成任务数
	counter_field :ct_finished_timeout, as: :created_tasks_finished_timeout_count do |counter|
	  counter.user.todo.created_tasks.completed._timeout.count
	end

	# 完成任务数
	counter_field :ct_finished_timeout, as: :created_tasks_finished_count do |counter|
	  counter.user.todo.created_tasks.completed._timeout.count
	end

	# 收到的任务 ( rt => received tasks )
	counter_field :rt_count, as: :received_tasks_count do |counter|
	  counter.user.todo.received_tasks.count
	end
	
	# 未完成的任务
	counter_field :rt_uncompleted, as: :received_tasks_uncompleted_count do |counter|
	  counter.user.todo.received_tasks.uncompleted.count
	end
	
	# 正在确认的任务
	counter_field :rt_confirming, as: :received_tasks_confirming_count do |counter|
	  counter.user.todo.received_tasks.completed.unconfirmed.count
	end
	
	# 按时完成的任务
	counter_field :rt_finished_ontime, as: :received_tasks_finished_ontime_count do |counter|
	  counter.user.todo.received_tasks.finished._untimeout.count
	end
	
	# 超时完成的任务
	counter_field :rt_finished_timeout, as: :received_tasks_finished_timeout_count do |counter|
	  counter.user.todo.received_tasks.finished._timeout.count
	end
	
	# 完成的任务
	counter_field :rt_finished_timeout, as: :received_tasks_finished_count do |counter|
	  counter.user.todo.received_tasks.finished.count
	end

	validates :user, presence: true, uniqueness: true
	attr_readonly :user
	
	before_create do |counter|
	  # 使用 user_id 作为 counter._id
		counter.id = counter.user_id
	end
	
	# 刷新所有统计数值
	def refresh!
    new_counters = {}
	  @@refreshable_fields.each do |key, block|
	    new_counters[key] = block.call(self)
	  end
	  update_attributes(new_counters)
	end

	class << self
	  def find_by_id(id)
		  where(:_id => id).first
	  end

	  def find_by_user_id(user_id)
		  where(:user_id => user_id).first
	  end
	end
end
