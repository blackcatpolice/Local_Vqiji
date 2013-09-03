# encoding: utf-8
# suxu
# 商店::商品管理
##
class Admin::ProductsController < Admin::BaseController
#layout proc { |controller| controller.request.xhr? ? nil : 'layouts/admin/store' }
  #load_and_authorize_resource :class => "Store::Product"
  
  #caches_page :index #缓存商品列表页面，在update和create后清除缓冲
  #
  def index
   @products = Store::Product.all.desc("end_date").paginate :page => params[:page], :per_page => 10
  end
  
  #
  def new
    @action = "create"
    @product = Store::Product.new
    #expire_page(:controller => 'store/products', :action => 'show')

  end
  
  #
  def create
    @product = Store::Product.new(params[:store_product])
    #expire_page(:action => 'index')

    @product.user_id = current_user.id;
    if @product.save
      redirect_to :action=>"index"
    else
      render :action=>"new"
    end
  end
  
  #
  def show
    @product = Store::Product.find(params[:id])
  end
  
  def edit
     @action = "update"
    @product = Store::Product.find(params[:id])
  end
  
  #admin::productC
  def update
    unless params[:has_styles]
      params[:store_product][:style_option] = nil
      params[:store_product][:styles] = nil
    end
    
    @product = Store::Product.find(params[:id])
      if @product.update_attributes(params[:store_product])
        #expire_page(:action => 'index')
       redirect_to :action=>"index"
      else
       render action: "edit"
      end
  end

  #
  def destroy
    @product = Store::Product.find(params[:id])
    @product.destroy
    expire_page(:action => 'index')
    redirect_to admin_products_url
  end
  
  
  
  
end
