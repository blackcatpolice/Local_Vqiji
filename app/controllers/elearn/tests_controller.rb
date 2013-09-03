# encoding: utf-8
# 培训测试
#
class Elearn::TestsController < Elearn::BaseController

  before_filter :find_training
  
  def index
    @training_user = TrainingUser.get(current_user.id,@training.id)
    @training_user.check = false
    @training_user.exam = false
    @training_user.score = 0
    @training_user.save

    if @training.timeout
      flash[:notice] = "培训已经过期，不能参与考试"
      redirect_to elearn_training_path(@training)
    elsif @training_user && @training_user.finished
      @tests = TrainingTest.where(:training_id=>@training.id,:page_id=>nil)
    else
      redirect_to elearn_training_path(@training)
    end
  end
  
  # 检查用户提交
  def check
    @tests = TrainingTest.where(:training_id=>@training.id,:page_id=>nil)
    @training_user = TrainingUser.get(current_user.id,@training.id)

    @training_user.score = 0
    @training_user.exam = true
    @training_user.check = true
    #判断是否回答正确
    @tests.each do |test|
      @training_user.check = false if test.subjective #如果存在主观题目
      @training_user.qas[test.id.to_s] = params[test.id.to_s]
      if test.objective  &&  test.answers == params[test.id.to_s] #比较答案
        @training_user.inc(:score,test.score)
        @training_user.score_hash[test.id.to_s] = test.score
      end
    end

    @training_user.pass = (@training.tests_count == 0 || @training_user.score >= @training.pass_score ) if @training_user.check
    
    @training_user.save
    redirect_to elearn_training_path(@training)
  end

  private 

  def find_training
    @training = Training.find(params[:training_id])
  end
end
