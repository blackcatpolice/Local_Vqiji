# encoding: utf-8
# 链接

require 'uri'
require 'neteasy/url_shortener'

module Rt
  class Url < Token
    field :url
    
    def serializable_hash(options = nil)
      {
        type: 'Url',
        url: url
      }
    end
    
    def to_html(options = nil)
      content_tag('a', url, href: url, class: 'url', target: '_blank', :'data-skip-pjax' => true)
    end

    require 'rt/url/errors'
    #require 'rt/url/shortener'
    #require 'rt/url/validation'
    #require 'rt/url/discern'
    #require 'rt/url/tokenizer'

    #require 'rt/url/generic'
    #require 'rt/url/tudou_video'
    #require 'rt/url/youku_video'

    extend Validation
    extend Tokenizer
    extend Shortener
    extend Discern
    
    extend TudouVideo::UrlExtends
    extend YoukuVideo::UrlExtends
  end
end
