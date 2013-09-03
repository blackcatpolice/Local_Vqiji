## encoding: utf-8
## 培训
##
class Admin::Elearning::TypesController < Admin::Elearning::BaseController
      
  def index
     @training_types = TrainingType.all.paginate :page => params[:page], :per_page => 5
  end

  def new
    @training_type = TrainingType.new
  end

  def create
    @training_type = TrainingType.new(params[:training_type])
    if @training_type.save
       redirect_to :action=>"index"
    else
       render :action => "new"
    end
  end

  def edit
    @action = "update"
    @training_type = TrainingType.find(params[:id])
  end

  def update
    @training_type = TrainingType.find(params[:id])
    @training_type.update_attributes(params[:training_type])
    redirect_to :action=>"index"
  end

  def destroy
  end
end
