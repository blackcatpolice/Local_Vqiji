#coding: utf-8

class Admin::ProposalsController < Admin::BaseController
  
   #layout proc { |controller| controller.request.xhr? ? nil : 'layouts/admin/fuwu' }

	def index
		@suggests = Proposal::Suggest.desc(:created_at).paginate(:page => params[:page], :per_page => 10)
	end
	
	def create
	
	end
	
	def edit
	
	end
	
	#同意
	def check
		@suggest = Proposal::Suggest.find(params[:id])
		@suggest.update_attributes(params[:proposal_suggest])
	  redirect_to admin_proposals_path
	end
	
	def destroy
		@suggest = Proposal::Suggest.find(params[:id])
		 
	 if not @suggest.picture.blank?
	 	@suggest.picture.delete
	 end
	 
	 if not @suggest.audio.blank?
	 	@suggest.audio.delete
	 end
	 
	 if not @suggest.file.blank?
	 	@suggest.file.delete
	 end
	 
	 @suggest.destroy
	 
	 redirect_to admin_proposals_path
	
	end
	
	def show
		@suggest = Proposal::Suggest.find(params[:id])
	end



end
