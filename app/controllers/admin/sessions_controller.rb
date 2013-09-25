# encoding: utf-8

class Admin::SessionsController < ApplicationController
  layout :nil
  #include SimpleSSLRequirement
  #include RenderJSONMessage
  
  def new
    @session = User::Session.new
  end
  
  #ssl_required
  
  # 登录
  #
  # == 参数:
  #  * email
  #  * password
  #
  # [json] 登录成功返回用户详细信息
  # [html] 跳转到主页 
  def create
    @session = User::Session.new(params[:user_session])
    
    begin
    @admin = Admin.login! @session
    redirect_to :controller=>"base",:action=>"store"
    rescue => error
      flash.notice = error.to_s
      render :action => :new, :status => :unauthorized
    end
  end
  
  def destroy
    current_session.destroy if current_session
    respond_to do |format|
      format.json {
        x_render_json_message '登出成功！'
      }
      format.any {
        flash.notice = "登出成功!"
        redirect_to :action => 'new'
      }
    end
  end
  
end

