class Todo::TaskCell < Cell::Rails

  helper :application,:users

  def my(args)
    service = args[:service]
    @tasks = service.find_unfinished_tasks_by(service.user).limit(5)
    render
  end

  def logs (args)
    @task = args[:task]
	  @logs = @task.logs.desc :created_at
    render
  end

  def value(args)
    @task = args[:task]
    @last_log = @task.logs.where("this.old_value != this.value").asc(:created_at).last
    render
  end

  def select(args)
  	service = args[:service]
  	user = args[:user]
  	@name = args[:name] || ""
  	@tasks = service.find_tasks_by_executor(user).only(:id,:title)
  	render
  end


  def value_form(args)
    service = args[:service]
    @user = args[:user]
    @task = args[:task]
    @log = service.new_log(:task => @task)
    @logs = @task.logs.where("this.old_value != this.value").asc(:created_at)
    render
  end

  def confirm_form(args)
    service = args[:service]
    @task = args[:task]
    render
  end



  def info(args)
    @task = args[:task]
  end

end
