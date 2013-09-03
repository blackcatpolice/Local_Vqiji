# encoding: utf-8

module Rt
  # 视频链接
  class Vurl < Token
    
    field :source # 源 (土豆/优酷...)
    field :title
    field :desc
    field :cvurl  # 封面图片 (cover url)
    field :plurl  # 播放链接 (play url)
    
    def serializable_hash(options = nil)
      {
        :type => 'VideoUrl',
        :url  => url,
        :source => source,
        :title => title,
        :desc => desc,
        :cover_url => cvurl,
        :play_url => plurl
      }
    end
    
    def to_html(options = nil)
      content_tag('a', "[视频: #{title}]",
        {
          class: 'video-url',
          href: url,
          title: desc,
          target: '_blank',
          :'data-source'    => source,
          :'data-play-url'  => plurl,
          :'data-cover-url' => cvurl,
          :'data-skip-pjax' => true
        }
      )
    end
    
    # 判断一条链接是否是视频链接
    def self.valid_url?(url)
      _url = Rt::Url.discern(url)
      !!(_url && (_url.to_token.is_a? Rt::Vurl))
    end
  end # Vurl
end
