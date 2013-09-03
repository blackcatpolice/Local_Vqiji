# todo subs controller
# @suxu
class Todo::CountsController < Todo::BaseController
	# actions
	def index
    @counts = @service.find_counts
	end

	def show
		@count = @service.find_count_by_id(params[:id])
	end

	def mine
		@count = @service.find_or_create_count_by_user(current_user)
		render :action=>"show"
	end
end
