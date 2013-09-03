# encoding: utf-8
# suxu
# 商店::商品管理
class Store::ProductsController < Store::BaseController
  
  before_filter :find_product_types
  #缓存商品详细界面
  #caches_page :show 
  #
  def index
    @exchange = true
    params[:exc] = @exchange 
    @products = Store::Product.query params
  end
  
  #
  def show
    @product = Store::Product.find(params[:id])
    Store::Viewed._create params[:id]
    #clicks = session["clicks"] || Array.new
    #clicks << params[:id] unless clicks.include? params[:id]
    #session["clicks"] = clicks
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
