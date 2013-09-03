#coding: utf-8

class Proposal::CommentsController < WeiboController

	layout "fuwu"
	before_filter :doctor_nav

	def index
	
	end
	
	def destroy
		@comment = Proposal::Comment.find(params[:id])
		
		if @comment.destroy
		 	@suggest = Proposal::Suggest.find(@comment.suggest_id)
    	@suggest.update_attribute(:comment_counts, @suggest.comment_counts-1)
		 
			respond_to do |f|
				f.json {render :json => @suggest.as_json(:only => [ :_id, :comment_counts ])}
			end
		end
	end
	
	def create
		
		@comment = Proposal::Comment._create :suggest_id => params[:suggestId], :content => params[:content], :audioId => params[:audioId]
		@comment.commenter_id = current_user.id
    if @comment.save 
    	@suggest = Proposal::Suggest.find(@comment.suggest_id)
    	@suggest.update_attribute(:comment_counts, @suggest.comment_counts+1)
    	commentJson = {"ccounts"=> @suggest.comment_counts, "data"=> @comment.as_json()} 
      respond_to do |format|
        format.json {render :json => commentJson}
      end
	  end 	
	end
	
	def show
		@page = params[:page].to_i==0 ? 1 : params[:page]
		
		@suggest = Proposal::Suggest.find(params[:id])
	  @comments = @suggest.comments.desc("created_at").paginate(:page => @page, :per_page => 5);
	 	
	 	commentJson = {"ccounts"=> @suggest.comment_counts, "data"=> @comments.as_json()}
	  
	  respond_to do |format|
      format.json { render :json => commentJson }
    end
	end
	

end
