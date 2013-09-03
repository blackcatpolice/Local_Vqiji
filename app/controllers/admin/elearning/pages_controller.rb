## encoding: utf-8
## 培训
##
class Admin::Elearning::PagesController < Admin::Elearning::BaseController
  #
  before_filter :get_training
  #
  def index
    @pages = @training.pages.asc("number").paginate :page => params[:page], :per_page => 10
  end
  
  #
  def show
    @page = TrainingPage.find(params[:id])
  end
  
  #
  def new
    @page = TrainingPage.new(:training_id=>params[:training_id])
  end
  
  #
  def create
   @page = TrainingPage.new(params[:training_page])
   @page.training = @training
   @page.save
   redirect_to :action=>"index"
  end
  
  #
  def edit
    @action = "update"
    @page = TrainingPage.find(params[:id])
  end
  
  #
  def update
    @page = TrainingPage.find(params[:id])
    @page.update_attributes(params[:training_page])
    redirect_to :action=>"show",:training_id=>@training.id,:id=>@page.id
  end
  
  #
  def destroy
    @page = TrainingPage.find(params[:id])
    @page.destroy
    redirect_to :action=>"index"
  end
  
  private
  
  def get_training
    @training = Training.find(params[:training_id])
  end
end
