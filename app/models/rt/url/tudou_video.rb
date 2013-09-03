# tudou_video

# 土豆视频链接
class Rt::Url
  class TudouVideo < Generic
    HOST = 'www.tudou.com'
    
    CONFIG = YAML.load_file("#{Rails.root}/config/tudou_video.yml")
    APP_KEY = CONFIG['app_key']
    
    OPTIONS = {
      :format => :json,
      :appKey => APP_KEY
    }.freeze
    
    def to_token(options = nil)
      _get_token
    end
    
    def valid?
      !!_get_token
    end
    
    private

    # 根据指定url查询出转帖信息
    # url: http://api.tudou.com/v3/gw?method=repaste.info.get&appKey=&format=&url=
    #
    def _get_repaste_info
      _query = OPTIONS.merge(:method => 'repaste.info.get', :url => long_url)
      _querystr = URI.encode_www_form(_query)
      _tudou_url = 'http://api.tudou.com/v3/gw?%s' % _querystr
      request!(_tudou_url)
    end
    
    def _create_token(json)
      _json = JSON.parse(json)
      _repaste_info = _json['repasteInfo']
      return nil unless (_repaste_info && (_itemInfo = _repaste_info['itemInfo']))
      
      Rt::Vurl.new(
        :source => 'Tudou',
        :url  => short_url,
        :title => _itemInfo['title'],
        :cvurl => _itemInfo['picUrl'],
        :desc => _itemInfo['description'],
        :plurl => _itemInfo['outerPlayerUrl']
      )
    end
    
    def _get_token
      @_retext ||= _create_token(_get_repaste_info)
    end
    
    def request!(url)
      _request = url.is_a?(URI) ? url.open : open(url.to_s)
      _response = _request.read
      return _response
    ensure
      _request.close if _request
    end
    
    module UrlExtends
      def self.extended(base)
        base.class_eval do
          _register_video_provider(HOST, TudouVideo)
        end
      end
    end
  end
end
