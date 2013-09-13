## encoding: utf-8
##
##用户
class Admin::UsersController < Admin::BaseController
  #
  def index
    @users = User.desc([ :check_at, :created_at ])
    @users = @users.where(:pinyin_index => "!") if params[:ch] == "!"
    @users = @users.where(:pinyin_index => params[:ch].downcase) if ("A" .. "Z").include?(params[:ch])
    @users = @users.paginate :page => params[:page], :per_page => 20
  end

  def search
    @users = User.all.desc(:created_at)
    unless params[:key].blank?
      reg = /#{params[:key]}/i
        @users = @users.where("$or"=>[
          { :name => reg },
          { :job_no => reg },
          { :job => reg }
        ])
    end
    @users = @users.paginate(:page => params[:page], :per_page => 20)
  end

  def list
    @users = User.all.paginate(:page => params[:page], :per_page => 20)
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
    if _user = params[:user]
      if (_user[:password].blank? || _user[:password_confirmation].blank?)
        _user.delete(:password)
        _user.delete(:password_confirmation)
      end
      _user.delete(:email) if _user[:email].blank?
      if !@user.update_attributes( _user, :as => :admin )
        render :action => "edit" and return
      end
    end
    redirect_to :action => "index"
  end
  
  #
  def gets
    @users =  User.where("department_id" => params[:departId]) if params[:departId]
  end
end
