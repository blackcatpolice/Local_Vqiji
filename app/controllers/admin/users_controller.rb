## encoding: utf-8
##
##用户
class Admin::UsersController < Admin::BaseController
  #
  def index
    @users = User.desc("checked").desc("created_at")
    @users = @users.where(:pinyin_index => "!") if params[:ch] == "!"
    @users = @users.where(:pinyin_index => params[:ch].downcase) if ("A" .. "Z").include?(params[:ch])
    @users = @users.paginate :page => params[:page], :per_page => 10
  end

  def home
    
  end

  def search
    @users = User.all.desc("created_at")
    unless params[:key].blank?
      reg = /#{params[:key]}/i
        @users = @users.where("$or"=>[{:name => reg },{:job_no => reg },{:job => reg }])
    end
    @users = @users.paginate :page => params[:page], :per_page => 20
  end

  def list
    @users = User.all.paginate :page => params[:page], :per_page => 10
  end

  def show
    @user = User.find params[:id]
  end

  def new
    @user = User.new
    @departments = Department.all
  end

  def create
    @user = User.new params[:user], :as => :admin
    @user.save
    redirect_to :action => "index"
  end

  def edit
    @user = User.find params[:id]
    @departments = Department.all
  end 

  def update
    @user = User.find params[:id]
    @departments = Department.all
    if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end
    if @user.update_attributes params[:user], :as => :admin
      redirect_to :action => "index"
    else
      render :action => "edit"
    end
  end
  
  #
  def gets
    @users =  User.where("department_id" => params[:departId]) if params[:departId]
  end
  
  
end
