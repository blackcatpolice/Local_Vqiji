#专题类型
## encoding: utf-8
##
class Admin::Atype::BlogtypesController < Admin::BaseController
  #layout proc { |controller| controller.request.xhr? ? nil : 'layouts/admin/fuwu' }  
  
  def index
     @rtypes = Blog::Type.all.paginate :page => params[:page], :per_page => 20
  end

  def new
    @rtype = Blog::Type.new
  end

  def create
    @rtype = Blog::Type.new(params[:blog_type])
    if @rtype.save
       redirect_to :action=>"index"
    else
    	render :new
    end
  end

  def edit
    @blog_type = Blog::Type.find(params[:id])
  end

  def update
    @rtype = Blog::Type.find(params[:id])
    @rtype.update_attributes(params[:blog_type])
    redirect_to :action=>"index"
  end

  def view
  	@rtype = Blog::Type.find(params[:id])
  	@rtype.isview = @rtype.isview? ? false : true
    if @rtype.save
    	flash.notice = "success"
    else
    	flash.notice = "fail"
    end
    redirect_to :action => "index"
  end

end
