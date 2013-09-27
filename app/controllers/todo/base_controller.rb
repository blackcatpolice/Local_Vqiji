class Todo::BaseController < WeiboController

  layout ->(c) { pjax_request? ? pjax_layout : 'todo' }
  
  before_filter :set_service
  
  protected
  
  def set_service
    @service = current_user.todo
  end
end
