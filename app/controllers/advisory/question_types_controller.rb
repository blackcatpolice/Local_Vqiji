#coding: utf-8
class Advisory::QuestionTypesController < WeiboController
  layout "advisory"
  
  def show
    @question_type = QuestionType.find(params[:id])
    @question_types = QuestionType.enables.asc(:priority)
    @questions = Question.includes(:owner).find_by_question_type(@question_type.id).desc(:created_at).paginate(:page => params[:page], :per_page => 10)
  end
end