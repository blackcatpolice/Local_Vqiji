# encoding: utf-8

require 'x_render_json'

# 链接控制器
class UrlsController < ActionController::Base
  include XJSONRender
  
  respond_to :json

  #caches_action :shorten, :expand, :cache_path => ->(req) { req.params }

  # 创建短链接
  def shorten
    _url = params[:url]
    
    render :json => {
      :url => _url,
      :shorten => Rt::Url.shorten(_url)
    }
  end
  
  # 展开短链接
  def expand
    _url = params[:url]
    
    render :json => {
      :url => Rt::Url.expand(_url),
      :shorten => _url
    }
  end
  
  # 验证视频链接
  def valid_video_url
    _url = params[:url]
    if Rt::Vurl.valid_url?(Rt::Url.expand(_url))
      render :json => {
        :url => _url,
        :shorten => Rt::Url.shorten(_url)
      }
    else
      x_render_json_error(:bad_request, '请输入正确的视频链接！')
    end
  end
  
  rescue_from Rt::Url::InvalidError, :with => :invalid_url_error
  
  protected
  
  # Rt::Url::InvalidError
  def invalid_url_error(error)
    x_render_json_error(:bad_request, '不支持的链接！')
  end
end

