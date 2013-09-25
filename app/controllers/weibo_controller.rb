# encoding: utf-8

class WeiboController < ApplicationController
  include My::Feeds::NewsHelper

  before_filter :authenticate_user!
  layout proc { |c| pjax_request? ? pjax_layout : 'weibo' }
  
  # rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  rescue_from WeiboError, :with => :weibo_error
  
  protected
  
  # WeiboError
  def weibo_error(error)
    respond_to do |format|
      format.json {
        render_json_error(error.http_status, error.message, error.code)
      }
    end
  end
  
  # Record Not Found
  def record_not_found
    respond_to do |format|
      format.json {
        render_json_error(:not_found, '您请求到对象不存在或已被删除！')
      }
    end
  end
  
  def doctor_nav
  	if current_user.doctor
      # render "public/404.html"
			render :text => "你无权访问该页面!   <a href='/'>返回微博首页</a>"
  	end  
  end
end
