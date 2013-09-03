class TestsController < WeiboController

	def index
		@pages = User.all.size/2
	end
	
	def list
		@page = params[:page]
		@count = User.all.size
		@users = User.paginate(:page => params[:page], :per_page => 2)
		respond_to do |f|
			f.json { render :json => @users.as_json()}
		end
	end

end
