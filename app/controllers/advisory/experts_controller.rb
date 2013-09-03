#coding: utf-8
class Advisory::ExpertsController < WeiboController
  layout "advisory"
  def index
  end
  
  def show
    @expert = Expert.includes(:user, :expert_type).find params[:id]
    @question = Question.new
  end
  
  def solved
    @questions = Question.expert_question(current_user.expert.id).solved.desc(:solved_at).paginate(:page => params[:page], :per_page => 10)
     # 清除问题解决通知
    current_user.notification.reset!(Notification::AdvisoryQuestionSolved) if (@questions.current_page == 1)
  end
  
  def unsolved
    @questions = Question.expert_question(current_user.expert.id).unsolved.desc(:replied_at, :created_at).paginate(:page => params[:page], :per_page => 10)
    # 清除新问题通知
    current_user.notification.reset!(Notification::NewAdvisoryQuestion) if (@questions.current_page == 1)
  end
  
  def update
    data = {:status => 1, :msg => "修改成功!"}
    expert = Expert.find params[:id]
    if expert.user_id != current_user.id
      raise WeiboError.new("你没有权限修改专家简介")
    end
    expert.update_attributes(params[:expert])
    respond_to do |format|
      format.json { render :json => data }
    end
  end
end
