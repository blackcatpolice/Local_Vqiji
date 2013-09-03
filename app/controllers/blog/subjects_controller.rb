#coding: utf-8
class Blog::SubjectsController < WeiboController
	layout "fuwu"
	before_filter :doctor_nav
	
	def index
	  @page = "blogs"
	  #显示的专题
	  @blog_types = Blog::Type.includes(:subjects).where(:isview=>true).asc(:position)
	end

	def show
		@subject = Blog::Subject.includes(:type).find(params[:id])
	end 
	
	def spheres
		@spheres = Blog::Type.find(params[:id])
		@p_one = params[:page].to_i || 1
		@subjects = Blog::Subject.where(:visible => true, :spheres => @spheres.id)
								.desc(:created_at).paginate(:page => params[:page], :per_page => 10)
	end
	
end
