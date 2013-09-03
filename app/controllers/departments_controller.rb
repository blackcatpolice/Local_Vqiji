# encoding: utf-8

class DepartmentsController < WeiboController

  def index
    @departments = Department.all
    
    respond_to do |format|
      format.json
    end
  end
  
  # 获取部门扁平数据
  def flat
    @departments = Department.all
    
    respond_to do |format|
      format.json
    end
  end
  
  def members
    @department = Department.find(params[:id])
    @members = @department.members
    
    respond_to do |format|
      format.json
    end
  end

  def cell
    render :layout => nil
  end

end
