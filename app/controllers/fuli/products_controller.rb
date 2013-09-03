# encoding: utf-8
# suxu
# 商店::商品管理
class Fuli::ProductsController < Fuli::BaseController
  
  before_filter :find_product_types
  #
  def index
    @exchange = true
    params[:exc] = @exchange 
    @products = Store::Product.query params
  end
  
  #
  def show
    @product = Store::Product.find(params[:id])
  end
  
  def unexchange
    @exchange = false
    params[:exc] = @exchange 
    @products = Store::Product.query params
    render :template => 'store/products/index'
  end
  
  private
  def find_product_types
    @product_types = Store::ProductType.base_scope
  end
  
  
end
