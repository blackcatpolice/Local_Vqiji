# encoding: utf-8
# suxu
# 
class Store::InvoicesController < Store::BaseController
  
  def index
    @invoices = Store::Invoice.user_scope(current_user.id).desc("created_at").paginate :page => params[:page], :per_page => 10
  end
  #
  def show
    @invoice = Store::Invoice.find(params[:id])
  end
  
   #新建发票报销申请
  def new
    begin
     @product = Store::Product.find(params[:pid])
     @invoice = Store::Invoice.new(:product_id=>@product.id,:product_name=>@product.name,:product_type=>@product.product_type)
     #@invoice.price = @product.price
     # @invoice = Store::Invoice.new()
    rescue => error
      render :text => "======#{error.to_s}"
    end
  end
  
  #
  def from
    
  end
  
  #创建发票报销申请
  def create
    @invoice = Store::Invoice.new(params[:store_invoice])
    @invoice.user_id = current_user.id
    #
    begin
       @invoice._save
       redirect_to :action=>"show",:id=>@invoice.id
    rescue => error
      flash.notice =  error.to_s
      render :text => "#{error.to_s}"
    end
    
  end
  
end
  
