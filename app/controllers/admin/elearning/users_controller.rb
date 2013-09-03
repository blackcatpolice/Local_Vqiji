# encoding: utf-8

class Admin::Elearning::UsersController < Admin::Elearning::BaseController
  #
  before_filter :get_training
  
  def index
    @training_users = @training.users.paginate(:page => params[:page], :per_page => 20)
  end
  
  def show
    @tu = TrainingUser.find(params[:id])
    # @tests = @training.tests
  end

  def new
    @training_users = @training.users
  end

  def save
    params[:users] = Array.new unless params[:users] #
    @training.set_users(params[:users])
    redirect_to :action=>"index"
  end
  
  def destroy
    @training_user = TrainingUser.find(params[:id])
    @training_user.destroy
    redirect_to :action=>"index", :page => params[:page]
  end
  
  def result
    @tu = TrainingUser.find(params[:id])
    @tests = TrainingTest.where(:training_id=>@training.id,:page_id=>nil).asc("type")
  end
  
  def score
    @training_user = TrainingUser.find(params[:id])
    @tests = TrainingTest.sub_scope(@training.id) # 得到所有主观题目
    score = 0
    @tests.each do |test|
      score = params[test.to_param].to_i
      @training_user.score_hash[test.to_param] = score
      @training_user.inc(:score, score)
    end
    @training_user.check = true
    if (@training_user.score >= @training.pass_score)
      @training_user.pass = true
      @training_user.save!
    end
    
    @training_user.save!
    
    # 发送 通过/未通过 通知
    if @training_user.pass
      # 发送测试通过通知
      Notification::ElearnTrainingPassed.notify!(@training_user)
    else
      # 发送测试未通过通知
      Notification::ElearnTrainingNotPass.notify!(@training_user)
    end
    
    redirect_to :action => 'result'
  end

  private

  def get_training
    @training = Training.find(params[:training_id])
  end
end
