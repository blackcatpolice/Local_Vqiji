# encoding: utf-8
# suxu
class Admin::ProductTypesController < Admin::BaseController
#layout proc { |controller| controller.request.xhr? ? nil : 'layouts/admin/store' }
  #load_and_authorize_resource :class => "Store::ProductType"
  
  # GET /store/product_types
  # GET /store/product_types.json
  def index
    @store_product_types = Store::ProductType.all.asc("parent")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @store_product_types }
    end
  end

  # GET /store/product_types/1
  # GET /store/product_types/1.json
  def show
    @store_product_type = Store::ProductType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @store_product_type }
    end
  end

  # GET /store/product_types/new
  # GET /store/product_types/new.json
  def new
    @store_product_type = Store::ProductType.new
    @action = "create"
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @store_product_type }
    end
  end

  # GET /store/product_types/1/edit
  def edit
    @action = "update"
    @store_product_type = Store::ProductType.find(params[:id])
  end

  # POST /store/product_types
  # POST /store/product_types.json
  def create
    @store_product_type = Store::ProductType.new(params[:store_product_type])
    respond_to do |format|
      if @store_product_type.save
        format.html { redirect_to :action=>"index" }
        format.json { render json: @store_product_type, status: :created, location: @store_product_type }
      else
        format.html { render action: "new" }
        format.json { render json: @store_product_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /store/product_types/1
  # PUT /store/product_types/1.json
  def update
    @store_product_type = Store::ProductType.find(params[:id])

    respond_to do |format|
      if @store_product_type.update_attributes(params[:store_product_type])
        format.html { redirect_to :action=>"index" }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @store_product_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /store/product_types/1
  # DELETE /store/product_types/1.json
  def destroy
    @store_product_type = Store::ProductType.find(params[:id])
    @store_product_type.destroy

    respond_to do |format|
      format.html { redirect_to admin_product_types_url }
      format.json { head :ok }
    end
  end
end
