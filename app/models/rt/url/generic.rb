# generic

class Rt::Url
  class Generic
    attr_reader :url
    
    def initialize(url)
      raise Rt::Url::InvalidError unless Rt::Url::valid?(url)
      @url = url
    end
    
    # 获取长链接
    def long_url
      @long_url ||= Rt::Url::expand(url)
    end
    
    # 获取短链接
    def short_url
      @short_url ||= Rt::Url::shorten(url)
    end
    
    # 将 url 转换为一个 rtext token，使其可以嵌入微博
    def to_token(options = nil)
      Rt::Url.new(:url => short_url)
    end
  end
end
