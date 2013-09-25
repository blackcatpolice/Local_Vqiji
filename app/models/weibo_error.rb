# encoding: utf-8

class WeiboError < StandardError
  attr_reader :code
  attr_reader :http_status
    
  def initialize(message = nil, code = 0, http_status = 500)
    super(message)
    @code = code
    @http_status = http_status
  end

  def message
    super || '未知错误！'
  end
end
