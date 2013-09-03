# encoding: utf-8
##suxu
class Admin::AdminsController < Admin::BaseController
  #layout proc { |controller| controller.request.xhr? ? nil : 'layouts/admin' }
  # GET /admins
  # GET /admins.json
  def index
    @admins = Admin.all
    respond_to do |format|
      format.html 
      format.json { render json: @admins }
    end
  end

  # GET /admins/1
  # GET /admins/1.json
  def show
    @admin = Admin.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @admin }
    end
  end

  # GET /admins/new
  # GET /admins/new.json
  def new
    @admin = Admin.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @admin }
    end
  end

  # GET /admins/1/edit
  def edit
    @admin = Admin.find(params[:id])
  end

  # POST /admins
  # POST /admins.json
  def create
    @admin = Admin.new(params[:admin])
    user = User.find_by_email(@admin.email)
    if user
       @admin.user_id = user.id 
       if @admin.save
         redirect_to :action=>"index" 
       else
         render action: "new" 
      end
    else
     #@msg = ""
     #flash["msg"] = "邮箱错误，没有对应的用户"
     flash.notice = "邮箱错误，没有对应的用户!"
     redirect_to :action=>"new" 
    end
  end

  # PUT /admins/1
  # PUT /admins/1.json
  def update
    @admin = Admin.find(params[:id])

    respond_to do |format|
      if @admin.update_attributes(params[:admin])
        format.html { redirect_to :action=>"index"  }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @admin.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admins/1
  # DELETE /admins/1.json
  def destroy
    @admin = Admin.find(params[:id])
    @admin.destroy

    respond_to do |format|
      format.html { redirect_to :action=>"index"}
      format.json { head :ok }
    end
  end
  
end
