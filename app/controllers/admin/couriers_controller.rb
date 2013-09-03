## encoding: utf-8
class Admin::CouriersController < Admin::BaseController
  #layout proc { |controller| controller.request.xhr? ? nil : 'layouts/admin/store' }
  def index
    @couriers = Courier.all.paginate :page=>params[:page],:per_page=>5
  end
  
  
  def new
    @action = "create"
    @courier = Courier.new
  end
  
  
  def create
    @courier = Courier.create(params[:courier])
    if @courier.save
      redirect_to admin_couriers_path()
    end
  end
  
  
  def edit
    @action = "update"
    @courier = Courier.find(params[:id])
  end
  
  
  def update
    courier = Courier.find(params[:id])
    if courier.update_attributes(params[:courier])
      redirect_to admin_couriers_path()
    end
  end
  
  
  def destroy
    courier = Courier.find(params[:id])
    if courier
      courier.destroy
    end
    redirect_to admin_couriers_path()
  end
end