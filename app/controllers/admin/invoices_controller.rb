# encoding: utf-8
# suxu
# 

class Admin::InvoicesController < Admin::BaseController
  #layout proc { |controller| controller.request.xhr? ? nil : 'layouts/admin/store' }
  def index
    @invoices = Store::Invoice.all.paginate :page => params[:page], :per_page => 10
  end
   #部门审核
  def dept
    @invoices = Store::Invoice.dept_scope.paginate :page => params[:page], :per_page => 10
  end
  def website
    @invoices = Store::Invoice.website_scope.paginate :page => params[:page], :per_page => 10
  end
  #人事审核
  def hr
    @invoices = Store::Invoice.hr_scope.paginate :page => params[:page], :per_page => 10
    #render :template=>"index"
  end
 
  
  def show
    @invoice = Store::Invoice.find(params[:id])
  end
  
  def update_step
    @invoice = Store::Invoice.find(params[:id])
    if @invoice.update_attributes(:step=>params[:step])
      redirect_to :action=>"index"
    else
      render :text=>"error"
    end
  end
  
  #
  def update
    @invoice = Store::Invoice.find(params[:id])
    params[:user_id] = current_user.id
    begin
      @invoice._update params
    rescue => error
      flash.notice =  error.to_s
    end
     redirect_to :action=>"show"
  end
  
  def destroy
    @invoice = Store::Invoice.find(params[:id])
    @invoice.destroy
    redirect_to :action=>"index"
  end
  
end
  
