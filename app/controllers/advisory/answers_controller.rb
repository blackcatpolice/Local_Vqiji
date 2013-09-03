#coding: utf-8
class Advisory::AnswersController < WeiboController
  
  def create
    @question = Question.find(params[:question_id])
    answer = @question.answer!(:audio_id => params[:audioId], :text => params[:text], :replier_id => current_user.id)
    respond_to do |format|
      format.html {
          render :partial => "advisory/tmpl/answer", :object => answer
       }
    end
  end
end
