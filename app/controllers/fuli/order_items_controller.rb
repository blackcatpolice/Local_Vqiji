# encoding: utf-8
# suxu
class Fuli::OrderItemsController < Fuli::BaseController
 #订单商品快照
 #订单项详细
  def show
     @order_item = Store::OrderItem.find(params[:id]);
  end
   
end

