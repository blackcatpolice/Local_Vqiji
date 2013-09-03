class Todo::BaseController < WeiboController
  layout proc { |c| pjax_request? ? pjax_layout : 'todo' }

    # filters
  before_filter do
    @service = current_user.todo
  end  
end
