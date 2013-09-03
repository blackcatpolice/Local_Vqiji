# encoding: utf-8
class Admin::KnowledgeTypesController < Admin::BaseController

	def index
		@knowledge_types = KnowledgeType.all.asc(:priority).desc(:created_at)
	end

	def new
		@knowledge_type = KnowledgeType.new
	end

	def create
		@knowledge_type = KnowledgeType.new params[:knowledge_type]
		if @knowledge_type.save
			redirect_to :action => "index"
		else
			render :action => "new"
		end
	end

	def edit
		@knowledge_type = KnowledgeType.find(params[:id])
	end

	def update
		@knowledge_type = KnowledgeType.find(params[:id])
		if @knowledge_type.update_attributes params[:knowledge_type]
			redirect_to :action => "index"
		else
			render :action => "edit"
		end
	end

	def destroy
		@knowledge_type = KnowledgeType.find params[:id]
		@knowledge_type.destroy
		redirect_to :action => "index"
	end
end