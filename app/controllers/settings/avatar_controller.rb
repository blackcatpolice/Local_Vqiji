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
    
    begin
      file.binmode
      file.write(request.raw_post)

      current_user.avatar = file
      
      current_user.save!
      x_render_json_message '更新头像成功！'
    ensure
      file.close(true) # 关闭并删除临时文件
    end
  end

end
