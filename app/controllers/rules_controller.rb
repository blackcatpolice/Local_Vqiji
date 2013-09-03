# encoding: utf-8

class RulesController < WeiboController

	layout "fuwu"
	before_filter :doctor_nav
	
	def index
	#	@rules = Rule.where(:visible => true, :btype => 1)
	  @page = "rules"
		@p_one = params[:page].to_i || 1
		@rules = Rule.where(:visible => true).desc(:created_at)
						 .paginate(:page => params[:page], :per_page => 10)
		@frule = Rule.where(:visible => true).desc(:created_at).first
		@types = RuleType.all
	end
	
	def show
		@rule = Rule.find(params[:id])
	end
	
	def read
		#@rule = Rule.find(params[:id])
		@isread = Isread.new(:message_id => params[:id], :reader_id => current_user.id, :message_type => "Rule")		
		@isread.save
		
		redirect_to rule_path(params[:id])
		
	end
	
	def search
		@type_id = params[:type_id]
		@p_one = params[:page].to_i || 1
		@rules = Rule.where(:visible => true, :rtype_id => params[:type_id])
						.desc(:created_at).paginate(:page => params[:page], :per_page => 10)
    @type = RuleType.find(params[:type_id]) if params[:type_id]
		@frule = Rule.where(:visible => true, :rtype_id => params[:type_id]).desc(:created_at).first
		@types = RuleType.all

		render "index"
	end
  
end
