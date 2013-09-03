# encoding = utf-8
class Admin::SubjectsController < Admin::BaseController
	#layout proc { |controller| controller.request.xhr? ? nil : 'layouts/admin/fuwu' }

	def index
		@subjects = Blog::Subject.desc("created_at")
							.paginate(:page => params[:page], :per_page => 10)
		@blog_types = Blog::Type.where(:isview => true)					
	end
	
	def new 
		@blog_subject = Blog::Subject.new
		@blog_types = Blog::Type.where(:isview => true)			
	end
	
	def create
		@subject = Blog::Subject.new(params[:blog_subject])
		if @subject.save
		#	flash[:notice] = "创建成功！"
			redirect_to admin_subjects_path
		else
			flash[:notice] = "三个选项不能为空～"
			redirect_to new_admin_subject_path
		end
	end
	
	def edit
	 	@blog_subject = Blog::Subject.find(params[:id])
	 	@blog_types = Blog::Type.where(:isview => true)	
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
		redirect_to admin_subjects_path
	end
	
	def visible
		@subject = Blog::Subject.find(params[:id])		
		@subject.visible = !@subject.visible
		@subject.save
		flash[:notice] = "更新成功"
		redirect_to admin_subjects_path
	end
	
	#标题时间
	def search 
		@page_title = "搜索结果"
		@blog_types = Blog::Type.all
		cons = Hash.new()
		if not params[:blog_subject][:spheres].blank?
			cons[:spheres] = params[:blog_subject][:spheres]
		end
		
		if not params[:blog_name].blank?
			cons[:title] = /.*#{params[:blog_name]}.*/
		end
		
		cons[:visible] = true
		@subjects = Blog::Subject.where(cons).desc("created_at")
							.paginate(:page => params[:page], :per_page => 10)
		
		render "index"
	end
	
	protected
	
end
