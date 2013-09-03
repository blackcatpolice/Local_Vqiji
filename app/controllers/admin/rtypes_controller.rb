#制度类型
## encoding: utf-8
##
class Admin::RtypesController < Admin::BaseController
  
  #layout proc { |controller| controller.request.xhr? ? nil : 'layouts/admin/fuwu' }
      
  def index
     @rtypes = RuleType.all.paginate :page => params[:page], :per_page => 5
  end

  def new
    @rtype = RuleType.new
  end

  def create
    @rtype = RuleType.new(params[:rule_type])
    if @rtype.save
       redirect_to :action=>"index"
    end
  end

  def edit
    @action = "update"
    @rtype = RuleType.find(params[:id])
  end

  def update
    @rype = RuleType.find(params[:id])
    @rtype.update_attributes(params[:rule_type])
    redirect_to :action=>"index"
  end

  def destroy
    
  end

end
