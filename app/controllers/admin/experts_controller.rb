## encoding: utf-8
class Admin::ExpertsController < Admin::BaseController
  def index
    @experts = Expert.includes(:user,:expert_type).paginate(:page => params[:page], :per_page => 10)
  end
  
  def new
    @user = User.new
    @expert = Expert.new
    @question_types = QuestionType.where(:status => 1).all
  end
  
  def create
    @user = User.new params[:user], :as => :admin
    @user.is_expert = true
    @user.checked = true
    @expert = Expert.new params[:expert]
    @expert.user_id = @user.id
    @question_types = QuestionType.where(:status => 1).all
    user_valid_tag = @user.valid?
    expert_valid_tag = @expert.valid?
    if user_valid_tag && expert_valid_tag && @user.save && @expert.save
      redirect_to :action => 'index'
    else
      @user.destroy 
      render :action => 'new'
    end
  end
  
  def edit
    @expert = Expert.find params[:id]
    @user = User.find @expert.user_id
    @question_types = QuestionType.where(:status => 1).all
  end
  
  def update
    @expert = Expert.find params[:id]
    @user = User.find @expert.user_id
    if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end
    if @user.update_attributes params[:user], as: :admin
      @expert.update_attributes params[:expert]
    end
    redirect_to :action => 'index'
  end
  
  def destroy
    expert = Expert.find params[:id]
    user = User.find expert.user_id
    if expert.destroy
      user.destroy 
    end
    redirect_to :action=>"index"
  end
  
  
  def disable
    expert = Expert.find params[:id]
    expert._modify(params[:status] || 0)
    redirect_to :action=>"index"
  end
end