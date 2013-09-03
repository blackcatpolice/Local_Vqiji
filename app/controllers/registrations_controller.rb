# encoding: utf-8
# 用户注册、激活已导入用户
# 
class RegistrationsController < Devise::RegistrationsController

	layout 'devise'

	def new
		@check = Check.find_by_id(params[:cid])
		unless @check
			#flash.notice = "需要确认您的身份!"
			redirect_to sign_up_check_path
		end
	end

	#
	def create
		@check = Check.find_by_id(params[:check_id])
		unless @check
			redirect_to sign_up_check_path
		end
		if @user = @check.active(params)
			sign_in("user", @user)
     		redirect_to "/"
     	else
     		redirect_to  new_user_registration_path(:cid=>@check.id.to_s)
		end
	end
end
