#coding: utf-8

class Proposal::SuggestsController < WeiboController
  layout "fuwu"
	before_filter :doctor_nav
	
	def index
	    @page = "suggests"
			@suggest = Proposal::Suggest.new
			@suggests = Proposal::Suggest.where(:check => 1).desc("created_at")
									.paginate(:page => params[:page], :per_page => 10)
	end
	
	def create
		@suggest = Proposal::Suggest._creates :title=>params[:title],:content=>params[:content],:sender_id=>current_user.id,:audioId=>params[:audioId],:pictureId=>params[:pictureId],:attachmentId=>params[:attachmentId]
    if @suggest
     # flash.notice = "您的建议正在审核当中，通过审核将会获取相应积分奖励，请耐心等待"
      redirect_to proposal_suggests_path, :suggest_message => @suggest_message
    else
      raise "提交建议失败，请重新填写～"
    end      
	
	end
	
	#我正在审核的
	def checking
	   @page = "checking"
			@suggest = Proposal::Suggest.new
			@suggests = Proposal::Suggest.where(:check => 2, :sender_id => current_user.id)
									.desc("created_at").paginate(:page => params[:page], :per_page => 10)	
	end
	
	#通过审核
	def checked
	   @page = "checked"
			# Unreads.reset!(current_user.id, 'suggestyes')
			@suggest = Proposal::Suggest.new
			@suggests = Proposal::Suggest.where(:check => 1, :sender_id => current_user.id)
									.desc("created_at").paginate(:page => params[:page], :per_page => 10)	
	end
	
	#未通过
	def refuse
	  @page = "refuse"
		# Unreads.reset!(current_user.id, 'suggestno')
		@suggest = Proposal::Suggest.new
		@suggests = Proposal::Suggest.where(:check => 0, :sender_id => current_user.id)
								.desc("created_at").paginate(:page => params[:page], :per_page => 10)	
	end
	
	
	def show
	
	end


end
