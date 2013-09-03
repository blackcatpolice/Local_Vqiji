# encoding: utf-8

class Admin::BaseController < ApplicationController
  layout 'admin'
  
  before_filter :authenticate_user!
  
  before_filter do
    redirect_to root_path unless current_user.is_admin
  end
  
  # rescue_from CanCan::AccessDenied do |exception|
  #   redirect_to :controller=>"base",:action=>"home", :alert => exception.message
  # end
end
