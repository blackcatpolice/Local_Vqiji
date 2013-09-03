# encoding: utf-8
# 培训页
#
class Elearn::PagesController < Elearn::BaseController
  before_filter :find_training
  
  def index
    @pages = @training.pages.asc("number").paginate :page => params[:page], :per_page => 1
    @page = @pages.first
    @training_user = TrainingUser.get(current_user.id,@training.id)
    #@tests = TrainingTest.where(:page_id=>@page.id,:type=>1) #当前页的题目
    render :action => "show"
  end
  
  def show
    @page = TrainingPage.find(params[:id])
    @training_user = TrainingUser.get(current_user.id, @training.id)
    @tests = TrainingTest.where(:page_id=>@page.id)
  end
  
  
  #下一页
  def next
    @page = TrainingPage.find(params[:id])
    @tests = TrainingTest.where(:page_id=>@page.id)
    @training_user = TrainingUser.get(current_user.id,@training.id)
    #判断是否回答正确
    @tests.each do |test|
      unless test.answers == params[test.id.to_s] #比较答案
        flash[:msg] = "请回答正确所有题目，进入下一页."
        render :action=>"show"
        return
      end
    end
    @training_user.pages << @page.id unless @training_user.pages.include? @page.id
    @training_user.save

    #如果还有下一页，进入下一页
    if @page.next_id
      #@training_user.update_attributes(:page_id=>@page.next_id) #修改进度
      redirect_to elearn_training_page_path(:training_id=>@training.id,:id=>@page.next_id)
    else #回到index
      if @training.tests_count == 0
        redirect_to check_elearn_training_tests_path(:training_id=>@training.id)
      elsif @training_user.finished
        redirect_to elearn_training_tests_path(:training_id => @training.id)        
      else
        flash[:msg] = "必须看完所有培训页，才能进入考试."
        render :action=>"show"
      end
    end
  end
  
  #
  private 
  def find_training
    @training = Training.find(params[:training_id])
  end

end
