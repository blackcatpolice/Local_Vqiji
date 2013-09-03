# todo tasks controller
# @suxu
class Todo::TasksController < Todo::BaseController
  # actions 
  def index
    @tasks = @service.find_tasks.paginate :page => params[:page], :per_page => 10
  end

  def mine
    @will_timeout_tasks = @service.will_timeout_tasks(current_user)
    @will_finish_tasks = @service.will_finish_tasks(current_user)
    @timeout_tasks = @service.timeout_tasks current_user
  end

  def myexecute
    @tasks = @service.find_tasks_by_executor(current_user).unfinished_scope.desc(:created_at).paginate :page => params[:page], :per_page => 10
    @list_title = "我收到的任务"
    @top_nav_class = "rw_nav1"
    render :template => "todo/tasks/list"
    
    # 清除新任务通知
    current_user.notification.reset!(Notification::NewTodoTask) if (@tasks.current_page == 1)
  end

  def mycreate
    @tasks = @service.find_tasks_by_creator(current_user).unfinished_scope.desc(:created_at).paginate :page => params[:page], :per_page => 10
    @list_title = "我分配的任务"
    @top_nav_class = "rw_nav2"
    render :template => "todo/tasks/list"
  end

  def finished
    @tasks = @service.find_tasks_by_executor_and_creator(current_user).finished_scope.desc(:completed_at).paginate :page => params[:page], :per_page => 10
    @list_title = "已完成的任务"
    @top_nav_class = "rw_nav3"
    render :template => "todo/tasks/list"
  end


  def bycreate
    @creator = @service.find_user_by_id(params[:user_id])
    @tasks = @service.find_tasks_by_creator(creator) if @creator
  end

  def byexecute
    @executor = @service.find_user_by_id(params[:user_id])
    @tasks = @service.find_tasks_by_executor(executor) if @executor
  end


  def new
  	@task = @service.new_task(:sup_id=>params[:sup_id])
  end

  def show
     @task_info = @service.find_task_by_id(params[:id])
     if @task_info.is_new && @task_info.executor == current_user
       @task_info.is_new = false
       @task_info.save
     end
     @task = @service.new_task(:sup_id=>@task_info.id)
  end

  def create
     @task = @service.create_task(params[:todo_task], params[:file_id], params[:picture_id])
     if @service.pass
         redirect_to todo_task_path(@task)
     else
        unless @task.sup_id.blank?
          @task_info = @service.find_task_by_id(@task.sup_id)
          render :action => "show"
        else
          render :action => "new"
        end
     end
  	 
  end

  def confirm
    @task = @service.find_task_by_id(params[:id])
    @service.confirm_task(@task)
    redirect_to todo_task_path(@task)
  end

  def update
  	 @task = @service.find_task_by_id(params[:id])
     @service.update_task(@task,params[:todo_task])
     redirect_to todo_task_path(@task)
  end

  def edit
     @task = @service.find_task_by_id(params[:id])
  end

  def destroy
    @task = @service.find_task_by_id(params[:id])
    @service.destroy_task(@task) 
    redirect_to mine_todo_tasks_path()
  end
  
  def executors
    executors = []
    executors = @service.find_users_by_name params[:name] unless params[:name].blank?
    render :json => executors
  end
  
  
  #只能看到  当前节点的子节点、当前节点、当前节点的父节点、父节点的父节点...(一直递归到根节点), 
  def treeview
    task = @service.find_task_by_id(params[:id])
    nodes = []
    unless params[:get_children_nodes].blank?
      nodes = task.to_tree_node.children
    else
      root_node = get_parent_tree({ :task => task, :tree_node => task.to_tree_node({:classes => "current"})})
      nodes << root_node
    end
    render :json => nodes
  end


  def progress
    data = { :status => 200, :ticks => [], :markings => [], :data => []}
    task = @service.find_task_by_id(params[:id])
    logs = task.logs.where("this.old_value != this.value").asc(:created_at)

    unless logs.blank?
      data[:min] = logs.first.created_at <= task.start_date ? logs.first.created_at.to_i * 1000 : task.start_date.to_i * 1000
      #data[:max] = logs.last.created_at > task.end_date ? logs.last.created_at.to_i * 1000 : task.end_date.to_i * 1000
    else
      data[:min] = task.start_date.to_i * 1000
    end
    if task.schedule == Todo::Task::SCHEDULE_COMPLETED
      data[:max] = task.end_date.to_i > task.confirm_at.to_i ? task.end_date.to_i * 1000 : task.confirm_at.to_i * 1000
    else
      data[:max] = task.end_date.to_i > Time.now.to_i ? task.end_date.to_i * 1000 : Time.now.to_i * 1000      
    end
    
    data[:ticks] << data[:min]
    #data[:ticks] << task.end_date.to_i * 1000 if !logs.blank? && logs.last.created_at > task.end_date 
    data[:ticks] << data[:max]

    data[:data] << [data[:min], 0]
    logs.each do |l|
      data[:data] << [l.created_at.to_i * 1000, l.value]
    end
    data[:markings] = [{ :xaxis => { :from => task.end_date.to_i * 1000, :to => task.end_date.to_i * 1000 }, :color => "red" }]

    render :json => data
  end

  def my_tasks
    @tasks = @service.find_unfinished_tasks_by(current_user).limit(5)
    render :json => @tasks.as_json
  end
  
  private 
  
  #opts = { :task => task, :children => task.children}
  #递归获取根节点
  #当前节点的子节点  和  父节点
  def get_parent_tree opts 
    node = opts[:tree_node]
    unless opts[:task].sup.blank?
      sub_task = opts[:task].sup # 父任务
      node = get_parent_tree( { :task => opts[:task].sup, :tree_node => Todo::TreeNode.new(:id => sub_task.id, :text => sub_task.title, :children => [node], :creator => sub_task.creator.name, :executor => sub_task.executor.name) })
    end
    return node
  end
end
