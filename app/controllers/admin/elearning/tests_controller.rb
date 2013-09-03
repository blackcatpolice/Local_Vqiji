## encoding: utf-8
## 培训
##
class Admin::Elearning::TestsController < Admin::Elearning::BaseController
  
 before_filter :get_training
  
  def index
    @tests = @training.tests
      .paginate(:page => params[:page], :per_page => 10)
  end
  
  def show
    @test = TrainingTest.find(params[:id])
  end
  
  def new
    @test = TrainingTest.new()
  end
  
  def create
    @test = TrainingTest.new(params[:training_test])
    @test.training_id = @training.id
    @test.save
    redirect_to :action=>"show",:training_id=>@test.training_id,:id=>@test.id
  end
  
  def edit
   @action = "update"
   @test = TrainingTest.find(params[:id])
  end
  
  def update
    @test = TrainingTest.find(params[:id])
    @test.update_attributes(params[:training_test])
    redirect_to :action=>"show",:training_id=>@test.training_id,:id=>@test.id
  end
  
  def destroy
    @test = TrainingTest.find(params[:id])
    @test.destroy
    redirect_to :action=>"index"
  end
  
  private
  
  def get_training
    @training = Training.find(params[:training_id])
  end
end
