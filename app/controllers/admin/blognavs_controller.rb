# encoding = utf-8
class Admin::BlognavsController < Admin::BaseController

  #layout proc { |controller| controller.request.xhr? ? nil : 'layouts/admin/fuwu' }
  
	def index
		@subjects = Blog::Subject.where(:visible => true, :btype => 2).paginate(:page => params[:page], :per_page => 10)
	end
	
	def new 
		@blog_subject = Blog::Subject.new			
	end
	
	def create
		@subject = Blog::Subject.new(params[:blog_subject])
		@subject.btype = 2
		if @subject.save
			render 'show'
		else
			flash[:notice] = "三个选项不能为空～"
			redirect_to new_admin_blognav_path
		end
	end
	
	def edit
	 	@blog_subject = Blog::Subject.find(params[:id])	
	end
	
	def update
	 	@subject = Blog::Subject.find(params[:id])	
	 	if @subject.update_attributes(params[:blog_subject])
	 		 render 'show'
	 	end
	end
	
	def show
		@subject = Blog::Subject.find(params[:id])	
	end
	
	def destroy
		@subject = Blog::Subject.find(params[:id])
		@subject.destroy
		redirect_to admin_blognavs_path
	end
	
	protected
	
end
