# encoding: utf-8

class Settings::AvatarController < Settings::BaseController
  def edit
  end

  # 使用 octet-stream 上传更新头像
  # == 参数: format
  #   format：文件格式, default: png
  #
  def octet_stream_update
    # 创建临时保存文件
    file = Tempfile.new(['foo', '.jpg'])
    file.binmode
    file.write(request.raw_post)

    current_user.avatar = file
    
    if current_user.save
      render_json_message '更新头像成功！'
    else
      raise Setting::Error, '设置头像失败！'
    end
  ensure
    if file
      file.close
      file.unlink # 删除文件
    end
  end
end
