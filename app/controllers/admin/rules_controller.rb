# encoding = utf-8
class Admin::RulesController < Admin::BaseController
  
  #layout proc { |controller| controller.request.xhr? ? nil : 'layouts/admin/fuwu' }
  
	def index
		@rules = Rule.desc("created_at").paginate(:page => params[:page], :per_page => 10)
	end
	
	def new 
		@rule = Rule.new			
	end
	
	def create
		@rule = Rule.new(params[:rule])
		@rule.creater_id = current_user.id
		if @rule.save
			@rtype = RuleType.find(@rule.rtype_id.to_s)
			@rtype.count = @rtype.count+1
			@rtype.save
			
			redirect_to admin_rules_path
		else
			flash[:notice] = "三个选项不能为空～"
			redirect_to new_admin_rule_path
		end
	end
	
	def edit
	 	@rule = Rule.find(params[:id])	
	end
	
	def update
	 	@rule = Rule.find(params[:id])	
	 	if @rule.update_attributes(params[:rule])
	 		 redirect_to admin_rules_path
	 	end
	end
	
	def show
		@rule = Rule.find(params[:id])	
	end
	
	def destroy
		@rule = Rule.find(params[:id])
		@rule.destroy
		redirect_to admin_rules_path
	end
	
	def isvisible
		@rule = Rule.find(params[:id])	
	
		if @rule.visible != true
			 @rule.visible = true
		else
			 @rule.visible = false
		end
		
		if @rule.save
			redirect_to admin_rules_path
	  else
	  	flash[:notice] = "error"
	  end
	end
	
	protected
	
end
