# encoding: utf-8

# 用户头像管理器
class User::AvatarsController < ActionController::Base
  # 头像存放路径
  USER_AVATAR_DIR           = File.join(Rails.root, 'public', 'users')
  # 默认头像地址
  DEFAULAT_AVATAR_DIR       = File.join(Rails.root, 'app', 'assets', 'images', 'defaults', 'user')

  caches_page :show

  # 
  # 获取用户头像
  #
  # == 参数：
  #  * user_id: 用户 id
  #  * size: 图片尺寸
  # == 例：
  # /users/1/avatar.png/50x50 => /public/users/1/v50x50_avatar.png
  # 返回指定版本的用户头像
  def show
    _path = File.join(USER_AVATAR_DIR, params[:user_id], _version_file_name)
    
    if (File.exists? _path)
      begin
        # 尝试发送用户设置图片
        _serve_png _path
      rescue ActionController::MissingFile
        # 失败，发送默认头像
        serve_default
      end
    else
      # 图片不存在，
      serve_default
    end
  end
  
  private
  # 发送默认头像
  def serve_default
    _serve_png File.join(DEFAULAT_AVATAR_DIR, _version_file_name)
  end
  
  # 图片文件名
  def _version_file_name
    # 头像图片名
    unless params[:size].blank?
      'v%s_avatar.%s' % [params[:size], params[:format]]
    else
      'avatar.%s' % params[:format]
    end
  end
  
  # 发送 png 图片文件
  def _serve_png(path)
    send_file path, :type => 'image/png', :disposition => 'inline'    
  end
end
