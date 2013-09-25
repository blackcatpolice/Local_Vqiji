# encoding: utf-8

module XRenderJSON

  # 渲染一个通用到标准的json格式的错误信息
  # == 参数：
  #  http_status：http 状态码，默认 500
  #   * 400 Bad Request
  #   * 403 禁止访问 (Forbidden)
  #   * 404 对象未找到 (Not Found)
  #   * 418 I'm a teapot
  #   * 500 服务器内部错误 (Internal Server Error)
  #   * 501 接口未实现 (Not Implemented)
  #  
  #  message: 错误说明，默认为空
  #  code:    详细错误码，默认为 0
  #   * -1 未知错误
  #   *  0 没有详细错误码， http 状态码已经够详细
  #
  def x_render_json_error(http_status = 500, message = nil, code = 0)
    x_render_inline_json(
      {
        :message => message,
        :code => code
      }.to_json,
      :status => http_status
    )
  end
  
  # 渲染一个通用到标准的消息
  def x_render_json_message(message)
    x_render_inline_json(
      { :message => message }.to_json
    )
  end
  
  # 对于较久浏览器异步文件上传一般使用 iframe 方式
  # 为了防止 ie, firefox 使用 iframe 上传文件后提示打开文件
  # 修改 content_type application/json 为 text/html
  # 实际内容仍然为 json
  # 另外一种实现方式：
  #   render :json => '12345', :content_type => 'text/html'
  def x_render_inline_json(json, opts = {})
    send_data(
      json,
      opts.merge(
        :type => 'text/html; charset=utf-8',
        :disposition => 'inline'
      )
    )
  end
end
