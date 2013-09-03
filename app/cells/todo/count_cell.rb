class Todo::CountCell < Cell::Rails

  helper :application,:users

  def my(args)
  	service = args[:service]
    @count = service.current_user_count
  	render
  end


end