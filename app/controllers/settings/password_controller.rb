# encoding: utf-8

class Settings::PasswordController < Settings::BaseController
  attr_accessible :current_password, :password, :password_confirmation
  
  def edit
  end

  def update
    if (current_user.update_with_password(user_params, as: :user))
      flash.now[:message] = '修改密码成功！'
      sign_in :user, current_user, :bypass => true # 重新登录
    end
    render 'edit'
  end

  protected
  
  def user_params
    sanitize_for_mass_assignment(params[:user])
  end

end
