## encoding: utf-8
##
## 部门
class Admin::DepartmentsController < Admin::BaseController
  
  def index
    #@departments = Department.all.paginate :page => params[:page], :per_page => 10
  end

  def list
  	@departments = Department.query(params).paginate :page => params[:page], :per_page => 10
  end
  
  def search
    @departments = Department.where("1==1").desc("created_at")
    unless params[:key].blank?
      reg = /#{params[:key]}/i
        @departments = @departments.where("$or"=>[{:name => reg }])
    end
    @departments = @departments.paginate :page => params[:page], :per_page => 10
  end

  def gets
    @departments = Department.where(:sup_id=>params[:sup_id])
   # render :json => Department.top_scope.to_json(:only => [:_id,:name,:subs])
    #render :json => {:depart=>}
  end

  def show
    @department = Department.find(params[:id])
  end

  def new
    @tops = Department.top_scope
  	@department = Department.new
  end

  def create
    @department = Department.new(params[:department])
    @department.creator = current_user
    if @department.save
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def destroy
    @department = Department.find(params[:id])
    @department.destroy
    redirect_to :action=>"list"
  end

  def users
    @department = Department.find(params[:id])
    @users = User.where(:department_id => nil) unless @department
    @users = @department.users if @department
    render :partial => "/admin/users/gets", :object => @users
  end
end
