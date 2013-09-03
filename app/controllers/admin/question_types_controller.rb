# coding: utf-8
class Admin::QuestionTypesController < Admin::BaseController
  
  def index
    @question_types = QuestionType.all.asc(:priority)
  end
  
  def new
    @question_type = QuestionType.new
  end
  
  def create
    @question_type = QuestionType.new(params[:question_type])
    if @question_type.save
      redirect_to :action => "index"
    else
      render :action => "new"
    end
  end
  
  def edit
    @question_type = QuestionType.find(params[:id])
  end
  
  def update
    @question_type = QuestionType.find(params[:id])
    if @question_type.update_attributes(params[:question_type])
      redirect_to :action => "index"
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @question_type = QuestionType.find(params[:id])
    @question_type.destroy
    redirect_to :action => 'index'
  end
  
  def disable
    question_type = QuestionType.find(params[:id])
    question_type._modify(params[:status] || 1)
    redirect_to :action => 'index'
  end
  
end
