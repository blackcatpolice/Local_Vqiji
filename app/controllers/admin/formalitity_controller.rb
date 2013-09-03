#coding: utf-8
class Admin::FormalitityController < Admin::BaseController
	#layout proc { |controller| controller.request.xhr? ? nil : 'layouts/admin/fuwu' }
	
	def index
		@formalities = Formalitity.desc("created_at").paginate(:page => params[:page], :per_page => 10)
	end
	
	def new 
		@formalitity = Formalitity.new			
	end
	
	def create
		@formality = Formalitity.new(params[:formalitity])
		@formality.creater_id = current_user.id
		if @formality.save
					
			redirect_to admin_formalitity_index_path
		else
			flash[:notice] = "三个选项不能为空～"
			redirect_to new_admin_formalitity_path
		end
	end
	
	def edit
	 	@formalitity = Formalitity.find(params[:id])	
	end
	
	def update
	 	@formality = Formalitity.find(params[:id])	
	 	if @formality.update_attributes(params[:formalitity])
	 		 redirect_to admin_formalitity_index_path
	 	end
	end
	
	def show
		@formality = Formalitity.find(params[:id])	
	end
	
	def destroy
		@formality = Formalitity.find(params[:id])
		@formality.destroy
		redirect_to admin_formalitity_index_path
	end
	
	def isvisible
		@formality = Formalitity.find(params[:id])	
	
		if @formality.visible != true
			 @formality.visible = true
		else
			 @formality.visible = false
		end
		
		if @formality.save
			redirect_to admin_formalitity_index_path
	  else
	  	flash[:notice] = "error"
	  end
	end

end
