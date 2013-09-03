# encoding: utf-8
# suxu
# 商店::商品管理
class Admin::OrdersController < Admin::BaseController
   #layout proc { |controller| controller.request.xhr? ? nil : 'layouts/admin/store' }
  # load_and_authorize_resource :class => "Store::Order"
    
  def index
    @orders = Store::Order.all.desc("created_at").paginate :page => params[:page], :per_page => 5
  end
  
  def destroy
    @order = Store::Order.find(params[:id])
    @order.destroy
    redirect_to :action=>"index"
  end
  
  def show
     @order = Store::Order.find(params[:id])
     @couriers = Courier.all if @order.status == 1
  end
  
  #拒绝订单
  def refuse
    @order = Store::Order.find(params[:id])
    @order.status = 5
    @order.save
  end
  
  def count
    
  end
  
  #修改订单 状态与发货时间
  def update
    @order = Store::Order.find(params[:id])
    @order._update params
    redirect_to :action=>"show"
  end
  
end
