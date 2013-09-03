# encoding: utf-8

class Admin::ExcelsController < Admin::BaseController

  def index
    @excel = Excel.new
    @excels = Excel.all.desc(:created_at)
  end
  
  def new
  end
  
  def create
    @excel = Excel.new(params[:excel]) do |excel|
      excel.uploader = current_user
    end
    @excel.save
    
    @excels = Excel.all.desc(:created_at)
    render 'index'
  end
  
  def show
  end
  
  def import
    @excel = Excel.find(params[:id])
    @excel.import! if @excel
    redirect_to :action => 'index'
  end
end
