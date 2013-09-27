class Todo::LogsController < Todo::BaseController

	def index
  	@task = @service.tasks.find(params[:task_id])
	end

	def new
  	@task = @service.tasks.find(params[:task_id])
		@log = @service.logs.new do |log|
		  log.task = @task
		end
	end

	def create
  	@task = @service.tasks.find(params[:task_id])
	  _log = params
	  
    picture = current_user.attachments.pictures.find_by_id(_log.delete(:picture_id)) if _log.key?(:picture_id) && !_log[:picture_id].blank?
    file = current_user.attachments.find_by_id(_log.delete(:file_id)) if _log.key?(:file_id) && !_log[:file_id].blank?
	  
		@log = @service.logs.new(_log) do |log|
		  log.task = @task
		  log.set_picture(picture) if defined?(picture) && picture
		  log.set_file(file) if defined?(file) && file
		end
		
		if @log.save
		  render :partial => "todo/logs/log", :locals => { :log => @log }
		else
		  raise WeiboError, @log.errors.full_messages.join(',')
		end
	end

end
