# coding: utf-8
class Admin::QuestionsController < Admin::BaseController
  #问题列表
	def index
	  @question_types = QuestionType.all
	  @questions = Question.includes(:expert, :owner).desc(:created)
	  @questions = @questions.where("$or" => [{ :title => /#{params[:keyword]}/i}, { :text => /#{params[:keyword]}/i}]) unless params[:keyword].blank?
	  @questions = @questions.where(:question_type_id => params[:question_type]) unless params[:question_type].blank?
	  @questions = @questions.where(:incognito => (params[:incognito] == "是" ? false : true)) unless params[:incognito].blank?
	  @questions = @questions.paginate :page => params[:page], :per_page => 10
	end
	
end
