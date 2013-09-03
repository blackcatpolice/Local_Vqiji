# discern

class Rt::Url
  module Discern
    @@providers = {}
    
    # 判断 url, 并返回具体的 url 实现
    def discern(url)
      _klass = @@providers[ URI(url).host ]
      (_klass || Generic).new(url)
    end
    
    private
    
    def _register_video_provider(host, klass)
      @@providers[ host ] = klass
    end
  end
end
