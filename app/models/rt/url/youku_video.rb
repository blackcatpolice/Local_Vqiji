# youku_video

# 优酷视频链接
class Rt::Url
  class YoukuVideo < Generic
    HOST = 'v.youku.com'
    
    CONFIG = YAML.load_file("#{Rails.root}/config/youku_video.yml")
    PID = CONFIG['pid']

    OPTIONS = {
      :rt => :JSON,
      :pid => PID
    }.freeze
    
    def to_token(options = nil)
      _get_token
    end
    
    def valid?
      !!_get_token
    end
    
    private

    # 根据视频ID得到视频的详细信息。
    # url: GET http://api.youku.com/api_ptvideoinfo
    #  pid	YOUKU合作ID
    #  id	视频ID	兼容优酷播放URL
    #  rt	返回数据类型	2.XML 3.JSON
    #
    def _get_videoinfo
      _query = OPTIONS.merge({
        :id => long_url
      });
      
      _querystr = URI.encode_www_form(_query)
      _youku_url = 'http://api.youku.com/api_ptvideoinfo?%s' % _querystr
      request!(_youku_url)
    end
    
    def _create_token(json)
      _json = JSON.parse(json)
      return nil unless _json
      
      _videoinfo = _json
      Tweet::Token::VideoUrl.new(
        :source => 'Youku',
        :url  => short_url,
        :name => _videoinfo['title'],
        :cover_url => _videoinfo['imagelink'],
        :description => _videoinfo['comment'],
        :play_url => _videoinfo['shareswf']
      )
    end
    
    def _get_token
      @_retext ||= _create_token(_get_repaste_info)
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
