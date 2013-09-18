module XSendFile
  def x_send_file(path, options = {})
    _args = options.merge( :x_sendfile => true )
    # FIXED: ie 下载文件包含中文名字时显示乱码
    if _args.key?(:filename) && (request.user_agent =~ /MSIE/i)
      _args[:filename] = CGI::escape(_args[:filename])
    end
    send_file path, _args
  end
end
