# encoding: utf-8
# 用户检查
class  ChecksController < ActionController::Base
	layout "devise"

	def new
		@check = Check.new
	end

	def create
		@check = Check.new(params[:check])
		if @check.execute
			redirect_to new_registration_path(:cid => @check.id)
		else
			render :action=>"new"
		end
	end
end
