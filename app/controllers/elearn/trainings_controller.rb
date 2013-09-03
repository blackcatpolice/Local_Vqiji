# encoding: utf-8
# 培训
#
class Elearn::TrainingsController < Elearn::BaseController
  # 未通过培训
  def index
    @items = TrainingUser.unpass_scope(current_user.id).desc(:updated_at)
      .paginate(:page => params[:page], :per_page => 9)
      
    if (@items.current_page == 1)
      # 清除新培训通知
      current_user.notification.reset!(Notification::NewElearnTraining)
      # 清除培训未通过通知
      current_user.notification.reset!(Notification::ElearnTrainingNotPass)
    end
  end

  #通过
  def pass
    @items = TrainingUser.pass_scope(current_user.id).desc("training.end_date")
      .paginate :page => params[:page], :per_page => 10
    render :template => "/elearn/trainings/index"
    # 清除通过通知
    current_user.notification.reset!(Notification::ElearnTrainingPassed) if (@items.current_page == 1)
  end

  #培训详细
  def show
     @training = Training.find(params[:id])
     @tu = TrainingUser.get(current_user.id,@training.id)
  end

  #重新开始
  def restart
    @training = Training.find(params[:id])
    @training_user = TrainingUser.get(current_user.id,@training.id)
    @training_user.update_attributes(
      :start => false,
      :page_id => nil,
      :pass => false,
      :finished => false,
      :exam => false,
      :check => false,
      :pass => false,
      :score => 0
    ) if @training_user
    @training_user.pages = Array.new
    @training_user.save
    redirect_to :action=>"show"
  end
  
  #重置进度
  def reset
    @training = Training.find_by_id(params[:id])
    @training_user = @training.users.where(:user_id=>current_user.id).first if @training
    @training_user.reset if @training_user
    redirect_to :action=>"show"
  end
end
