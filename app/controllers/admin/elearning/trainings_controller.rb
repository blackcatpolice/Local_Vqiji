## encoding: utf-8
## 培训
##
class Admin::Elearning::TrainingsController < Admin::Elearning::BaseController

  def home
  end
    
  def index
     @trainings = Training.all.desc(:updated_at)
      .paginate :page => params[:page], :per_page => 5
  end

  def new
    @training = Training.new
  end

  def create
    @training = Training.new(params[:training])
    
    @training.save
    redirect_to :action=>"show",:id=>@training.id
  end

  def edit
    @action = "update"
    @training = Training.find(params[:id])
  end

  def update
    @training = Training.find(params[:id])
    @training.update_attributes(params[:training])
    redirect_to :action=>"show",:id=>@training.id
  end
  
  #发布培训
  def release
    @training = Training.find(params[:id])
    if @training.release? #发布成功
      render :action=>"show"
    else
      render :action=>"show"
    end
  end
  
  #取消发布
  def cancel
    @training = Training.find(params[:id])
    @training.cancel()
    redirect_to :action=>"show",:id=>@training.id
  end

  def destroy
    @training = Training.find(params[:id])
    @training.destroy
    redirect_to :action=>"index"
  end
  
  def show
    @training = Training.find(params[:id])
  end
end
