# encoding: utf-8
# 用户注册、激活已导入用户
# 
class RegistrationsController < ActionController::Base
	layout 'devise'

	def new
		@check = Check.find_by_id(params[:cid])
		unless @check
			#flash.notice = "需要确认您的身份!"
			redirect_to new_check_path
		end
	end

	#
	def create
		@check = Check.find_by_id(params[:check_id])
		unless @check
			redirect_to(new_check_path) and return
		end
		
		if @check.active!(params[:user])
			sign_in('user', @check.user)
   		redirect_to '/'
   	else
   		render :new
		end
	end
end
