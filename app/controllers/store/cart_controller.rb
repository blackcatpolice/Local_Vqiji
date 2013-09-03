# encoding: utf-8
# suxu
# 商店购物车
class Store::CartController < Store::BaseController

  #得到当前用户的购物车
  before_filter:get_cart
  #
  
  #
  #当前购物车信息
  def index
    
  end
  
  #放入购物车
  def put
   @cart.add_to_cart params[:k],params[:v]
   @cart.save
   # redirect_to :action => "index"
   
   render :json=>{:status=>'success'}
  end
  
  #修改产品数量
  def update
    @cart.put params[:k],params[:v]
    @cart.save
    redirect_to :action => "index"
  end
  
  
  #移除购物车
  def remove 
    @cart.remove params[:k]
    @cart.save
    redirect_to :action => "index"
  end
  
  #批量移除购物车
  def removes
    @cart.remove params[:keys]
    @cart.save
    redirect_to :action => "index"
  end
 
  #结帐
  def checkout
    begin
    @order = @cart.create_order
    #清空购物车
    @cart.clear if params[:isclear] == "1"
    redirect_to :controller=>"orders",:action=>"show",:id=>@order.id
    rescue => error
      flash.notice =  error.to_s
      redirect_to :action=>"index"
    end
  end
  
  private 
  def get_cart
    @cart = Cart.get(current_user.id)
  end
   
  
end
