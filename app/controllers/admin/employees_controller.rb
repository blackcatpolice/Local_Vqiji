## encoding: utf-8
##
##
class Admin::EmployeesController < Admin::BaseController
  #layout proc { |controller| controller.request.xhr? ? nil : 'layouts/admin/system' }
  def new
    @action = 'create'
    
    @employee = Employee.new
    @groups = Work::Group.all
    @companies = Company.all
  end
  
  def show
    
  end
  
  def create
    group_ids = params.delete(:group_ids)
    @employee = Employee.new(params[:employee])
    @employee.group_ids = group_ids.join(",") if group_ids
    if @employee.save
      redirect_to :action=>"index"
    end
  end
  
  def update
  
  end
  
  def index
    @employees = Employee.paginate :page => params[:page], :per_page => 10
  end
  
  def destroy
    
  end
  
  
  
  
end
