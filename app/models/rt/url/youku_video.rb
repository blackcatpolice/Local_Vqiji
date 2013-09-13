# youku_video

# 优酷视频链接
class Rt::Url
  class YoukuVideo < Generic
    HOST = 'v.youku.com'
    
    CONFIG = YAML.load_file("#{Rails.root}/config/youku_video.yml")
    CLIENT_ID = CONFIG['pid']

    def to_token(options = nil)
      _get_token
    end
    
    def valid?
      !!_get_token
    end
    
    private

    # 根据视频ID得到视频的详细信息。
    # http://open.youku.com/docs/api/videos/show_basic
    #
    def _get_video_info
      _query = {
        :client_id => CLIENT_ID,
        :video_url => long_url
      }
      
      _querystr = URI.encode_www_form(_query)
      _youku_url = 'https://openapi.youku.com/v2/videos/show_basic.json?%s' % _querystr
      request!(_youku_url)
    end
    
    def _create_token(json)
      _videoinfo = JSON.parse(json)
      return nil unless _videoinfo
      
      Rt::Vurl.new(
        :source => 'Youku',
        :url  => short_url,
        :title => _videoinfo['title'],
        :cvurl => _videoinfo['thumbnail'],
        :desc => _videoinfo['description'],
        :plurl => _videoinfo['player']
      )
    end
    
    def _get_token
      @_retext ||= _create_token(_get_video_info)
    end
    
    def request!(url)
      begin
        _request = url.is_a?(URI) ? url.open : open(url.to_s)
        _response = _request.read
        return _response
      ensure
        _request.close if _request
      end
    end
    
    module UrlExtends
      def self.extended(base)
        base.class_eval do
          _register_video_provider(HOST, YoukuVideo)
        end
      end
    end
  end
end
