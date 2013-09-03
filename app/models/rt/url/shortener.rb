# shortener

class Rt::Url
  module Shortener
    SHORT_URLS_COLLECTION = 'short-URLs'
    LONG_URLS_COLLECTION = 'long-URLs'
    
    SHORT_URL_PATTERN = /^(http[s]?:\/\/)?126.am\//
    
    # 判断是否是短链接
    def shorten?(url)
      !!(SHORT_URL_PATTERN =~ url)
    end
    
    # 创建短链接
    def shorten(url)
      return url if shorten?(url)

      unless (_shortUrl = $redis.hget(SHORT_URLS_COLLECTION, url))
        _shortUrl = Neteasy::UrlShortener.shorten!(url)
        $redis.hset(SHORT_URLS_COLLECTION, url, _shortUrl)
        $redis.hset(LONG_URLS_COLLECTION, _shortUrl, url)
      end

      _shortUrl
    end
    
    # 展开短链接
    def expand(url)
      return url unless shorten?(url)

      unless (_longUrl = $redis.hget(LONG_URLS_COLLECTION, url))
        _longUrl = Neteasy::UrlShortener.expand!(url)
        $redis.hset(LONG_URLS_COLLECTION, url, _longUrl)
        $redis.hset(SHORT_URLS_COLLECTION, _longUrl, url)
      end

      _longUrl
    end
  end
end
