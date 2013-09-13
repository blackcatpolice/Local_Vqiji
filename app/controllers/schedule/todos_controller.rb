class Schedule::TodosController < Schedule::BaseController

  # 统计一月内每天任务数
  def month_count
    month = Date.parse(params[:month])
    @count = current_user.schedule.count_todos_by_month(month)
    render :json => @count
  end
  
  def fullday
    _date = Date.parse(params[:date])
    @todos = current_user.schedule.todos
      .in_range(_date.beginning_of_day, _date.end_of_day)
    render :layout => false
  end
  
  def create
    @todo = current_user.schedule.todos.new(todo_params)
    if @todo.save
      render :json => @todo.to_builder.target!
    else
      raise WeiboError, @todo.errors.full_messages.join(',')
    end
  end
  
  def destroy
    @todo = current_user.schedule.todos.find(params[:id])
    @todo.destroy
    render :json => true
  end
  
  protected
  
    def todo_params
      params.require(:todo).permit(:detail, :at)
    end
end
