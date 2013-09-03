# todo logs controller
# @suxu
class Todo::LogsController < Todo::BaseController
	before_filter do
  	@task = @service.find_task_by_id(params[:task_id])
	end

	def index
	end

	def new
		@log = @service.new_log(:task => @task)
	end

	def show
	end

	def create
	  todo_log = { :msg => params[:msg] || "...", :value => params[:value]}
	  todo_task = { :end_date => params[:end_date], :level => params[:level]}
		@log = @service.create_log(@task, todo_log, todo_task, params[:file_id], params[:picture_id])
		render :partial => "todo/logs/log", :locals => {:log => @log}
	end

	def destroy
	end
end
