#coding: utf-8
class Advisory::QuestionsController < WeiboController
  layout "advisory"
  
  def solved
    @questions = Question.user_questions(current_user.id).solved.desc(:solved_at).paginate(:page => params[:page], :per_page => 10)
  end
  
  def unsolved
    @questions = Question.user_questions(current_user.id).unsolved.desc(:replied_at, :created).paginate(:page => params[:page], :per_page => 10)
    current_user.notification.reset!(Notification::NewAdvisoryAnswer) if (@questions.current_page == 1)
  end
  
  def show
    opts = {}
    @question = Question.includes(:answers).find params[:id]
    opts[:click] = 1 if @question.owner_id != current_user.id && current_user.id != @question.expert.user.id
    opts[:expert_read]  = true if current_user.id == @question.expert.user.id
    opts[:expert_replys] = 0 if @question.owner_id == current_user.id
    opts[:owner_replys] = 0 if @question.expert.user.id == current_user.id
    @question.click(opts)
  end
  
  def create
    question = Question.new params[:question]
    question.owner_id = current_user.id
    question.info = params[:info] if params[:display].to_i == 1
    question.set_audio(params[:audio_id])
    question.case_history = params[:case_history] if params[:case_history] 
    if question.save
      redirect_to :action => :unsolved
    else
      redirect_to advisory_expert_path(question.expert_id)
    end
  end

  def destroy
    data = {:status => 1, :msg => "删除成功！"}
    question = Question.find params[:id]
    question._destroy!
    respond_to do |format|
      format.json { render :json => data }
    end
  end

  def solve_question
    data = {:status => 1, :msg => "问题已解决!"}
    question = Question.find params[:id]
    if(question.allow_delete)
      raise WeiboError.new("专家尚未回复问题, 不能更新问题状态!")
    end
    if question.owner_id != current_user.id
      raise WeiboError.new("你没有权限修改当前问题状态!");
    end
    question.review = params[:review] || Question::REVIEW_GREAT
    question.solved = true
    question.solved_at = Time.now
    question.save

    respond_to do |format|
      format.json { render :json => data }
    end
  end
end
