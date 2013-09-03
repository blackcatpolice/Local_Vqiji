require 'net/http'
require 'uri'
require 'json'
require 'date'

require 'neteasy/url_shortener/request'
require 'neteasy/url_shortener/base'
require 'neteasy/url_shortener/url'
require 'neteasy/url_shortener/errors'

module Neteasy
  module UrlShortener
    
    def self.shorten!(url)
      Url.new(:long_url => url).shorten!
    end
    
    def self.expand!(url)
      Url.new(:short_url => url).expand!
    end
  end
end
