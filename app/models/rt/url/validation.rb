# validation

class Rt::Url
  module Validation
    # URL Pattern
    # @regexp = /(http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
    # 仅 http 和 https 链接
    def regexp
      @regexp ||= URI.regexp(['http', 'https'])
    end
    
    # 验证是否是支持的 url
    def valid?(url)
      !!(regexp =~ url)
    end
  end
end
