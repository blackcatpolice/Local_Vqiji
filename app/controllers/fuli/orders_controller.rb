# encoding: utf-8
# suxu
class Fuli::OrdersController < Fuli::BaseController
  
  def index
    #paginate :page => params[:page], :per_page => 10
    @orders = Store::Order.user_scope(current_user.id).desc("submitted_at")
  end
  
  def show
     @order = Store::Order.find(params[:id])
     @contents = OrderContent.user_scope(current_user.id) if @order.status == 0
  end
  
  def edit
    @order = Store::Order.find(params[:id])
  end
  
  def submit
    @order = Store::Order.find(params[:id])
    content = OrderContent.find(:cid)
    content = OrderContent.new(params[:content])
    begin
      @order._submit params
      redirect_to :action=>"success",:id=>@order.id
    rescue => error
      flash.notice =  error.to_s
      redirect_to :action=>"show"
    end
  end
  
  def success
    @order = Store::Order.find(params[:id])
  end
  
  #确认订单收货
  def confirm
    @order = Store::Order.find(params[:id])
    @order.status = Store::Order::STATUS_CONFIRM
    @order.save
    redirect_to :action=>"show"
  end
  
  def destroy
    @order = Store::Order.find(params[:id])
    @order.destroy
    redirect_to :action=>"index"
  end
  
end
