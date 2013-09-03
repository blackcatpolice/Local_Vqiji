# encoding: utf-8

class ApplicationController < ActionController::Base
  include JSONMessageRender
  
  # protect_from_forgery :only => [:create, :update, :destroy]

  protected

  def pjax_layout
    'pjax'
  end

  # before_filter :set_locale

  # def set_locale
  #   I18n.locale = params[:locale] || I18n.default_locale
  # end

  # Sign out a user and tries to redirect to the url specified by
  # after_sign_out_path_for.
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
