# encoding: utf-8

class WeiboError < RuntimeError
  attr_reader :code
  attr_reader :http_status
    
  def initialize(message = nil, code = 0, http_status = 500)
    super(message)
    @code = code
    @http_status = http_status
  end
  
  def as_json(options = nil)
    {
      :message => (@message || '未知错误！'),
      :code => @code
    }
  end
  
  def to_json(options = nil)
    as_json.to_json
  end
end
