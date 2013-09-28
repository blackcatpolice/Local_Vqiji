class Todo::TasksController < Todo::BaseController

  def index
    @confirming_tasks = @service.created_tasks.completed.unconfirmed
    @will_timeout_tasks = @service.received_tasks.will_timeout
    @timeout_tasks = @service.received_tasks._timeout
  end

  def received
    @tasks = @service.received_tasks
                     .uncompleted.desc(:created_at)
                     .paginate :page => params[:page], :per_page => 10
  end

  def created
    @tasks = @service.created_tasks
                     .unconfirmed.desc(:created_at)
                     .paginate :page => params[:page], :per_page => 10
  end

  def received
    @tasks = @service.received_tasks
                     .desc(:created_at)
                     .paginate :page => params[:page], :per_page => 10

    render
    
    # 清除新任务通知
    current_user.notification.reset!(Notification::NewTodoTask) if (@tasks.current_page == 1)
  end

  def finished
    @tasks = @service.received_tasks
                     .finished.desc(:completed_at)
                     .paginate :page => params[:page], :per_page => 10
  end

  def show
    @task = @service.tasks.find(params[:id])

    render

    if (@task.is_new && @task.executor?(current_user))
      @task.update_attribute(:is_new, false)
    end
  end

  # 当前节点的子节点、当前节点、当前节点的父节点、父节点的父节点...(一直递归到根节点)
  def treeview
    @task = @service.tasks.find(params[:id])
  end

  def new
    _task = params[:todo_task] || {}

    executor = User.find_by_name(_task.delete(:executor_name)) if _task.key?(:executor_name) && !_task[:executor_name].blank?
    sup_task = @service.tasks.find_by_id(_task.delete(:sup_id)) if _task.key?(:sup_id) && !_task[:sup_id].blank?
    
  	@task = @service.created_tasks.new(_task) do |task|
		  task.executor = executor if defined?(executor)
		  task.sup = sup_task if defined?(sup_task)
		end
  end

  def create
    _task = params[:todo_task] || {}

    executor = User.find_by_name(_task.delete(:executor_name)) unless _task[:executor_name].blank?
    picture = current_user.attachments.pictures.find_by_id(_task.delete(:picture_id)) unless _task[:picture_id].blank?
    file = current_user.attachments.find_by_id(_task.delete(:file_id)) unless _task[:file_id].blank?
    
    _task_params = params.require(:todo_task).permit(:title, :details, :start_at, :end_at, :priority)

		@task = @service.created_tasks.new(_task_params) do |task|
		  task.executor = executor if defined?(executor)
		  task.set_picture(picture) if defined?(picture) && picture
		  task.set_file(file) if defined?(file) && file
		end
		
		if @task.save
		  flash.notice = '任务创建成功!'
      redirect_to todo_task_path(@task)
		else
		  flash.now[:error] = @task.errors.full_messages.join(',')
      render 'new'
		end
  end

  def edit
    @task = @service.created_tasks.unconfirmed.find(params[:id])
  end

  def update
  	@task = @service.created_tasks.unconfirmed.find(params[:id])
  	
  	_task = params[:todo_task]
  	picture = current_user.attachments.pictures.find_by_id(_task.delete(:picture_id)) unless _task[:picture_id].blank?
    file = current_user.attachments.find_by_id(_task.delete(:file_id)) unless _task[:file_id].blank?

  	task_params = params.require(:todo_task).permit(:title, :details, :start_at, :end_at, :priority)
  	
  	@task.instance_eval do |task|
    	task.assign_attributes(task_params)
		  task.set_picture(picture) if defined?(picture) && picture
		  task.set_file(file) if defined?(file) && file
  	end

		if @task.save
		  flash.notice = '修改任务成功!'
      redirect_to todo_task_path(@task)
		else
		  flash.now[:error] = @task.errors.full_messages.join(',')
      render 'edit'
		end
  end

  def destroy
    @task = @service.created_tasks.find(params[:id])
    @service.destroy_task(@task) 
    redirect_to :action => :created
  end
  
  def executors
    unless params[:name].blank?
      @executor_names = User.fuzzy_search_by_name(params[:name]).pluck(:name)
    end
    render :json => @executor_names || []
  end

  # 查看进度
  def progress
    @task = @service.tasks.find(params[:id])
  end
  
  # 更新进度
  def update_progress
    @task = @service.tasks.find(params[:id])

    _todo_task = params[:todo_task]
    _params = {}
    _params[:picture] = current_user.attachments.pictures.find(params[:picture_id]) unless params[:picture_id].blank?
    _params[:file] = current_user.attachments.find(params[:file_id]) unless params[:file_id].blank?
    
    @service.update_progress!(@task, _todo_task[:progress].to_i, params[:info], _params)
    
    # 创建人可以编辑基础信息
    if (@task.creator?(current_user))
      _task_params = params.require(:todo_task).permit(:end_at, :priority)
      @task.update_attributes!(_task_params)
    end
    
    redirect_to todo_task_path(@task)
  end

  def confirm
    @task = @service.created_tasks.unconfirmed.completed.find(params[:id])
    @service.confirm!(@task)
    redirect_to todo_task_path(@task)
  end
  
  # subs（子任务）

  def new_sub
    @task = @service.tasks.unconfirmed.find(params[:id])
    @sub_task = @task.subs.new do |task|
      task.end_at = @task.end_at
    end
  end
  
  def create_sub
    @task = @service.tasks.unconfirmed.find(params[:id])
    _task = params[:todo_task] || {}

    executor = User.find_by_name(_task.delete(:executor_name)) unless _task[:executor_name].blank?
    picture = current_user.attachments.pictures.find_by_id(_task.delete(:picture_id)) unless _task[:picture_id].blank?
    file = current_user.attachments.find_by_id(_task.delete(:file_id)) unless _task[:file_id].blank?
	  
    _task_params = params.require(:todo_task).permit(:title, :details, :start_at, :end_at, :priority)
    
		@sub_task = @task.subs.new(_task_params) do |task|
		  task.creator = current_user
		  task.executor = executor if defined?(executor)
		  task.sup = sup_task if defined?(sup_task)
		  task.set_picture(picture) if defined?(picture) && picture
		  task.set_file(file) if defined?(file) && file
		end
		
		if @sub_task.save
		  flash.notice = '创建子任务成功!'
      redirect_to todo_task_path(@sub_task)
		else
		  flash.now[:error] = @sub_task.errors.full_messages.join(',')
      render 'new_sub'
		end
  end

  def subs_treeview
    @task = @service.tasks.find(params[:id])
  end

end
