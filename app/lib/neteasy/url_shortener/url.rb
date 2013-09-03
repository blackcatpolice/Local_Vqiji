module Neteasy
  module UrlShortener
    class Url < Base
      include Request

      SHORTEN_URL = 'http://126.am/api!shorten.action'
      EXPAND_URL  = 'http://126.am/api!expand.action'

      attr_reader :long_url, :short_url

      def initialize(opts={})
        opts.each_pair do |k, v|
          self.instance_variable_set(:"@#{k}", v)
        end
      end

      def shorten!
        params   = validate_and_prepare_params(:longUrl => self.long_url)
        response = post(SHORTEN_URL, params)
        
        url = response['url']
        @short_url = (url && prepend_url_schema(url))
      end
      
      # FIXME: 不能正常工作～
      def expand!
        params   = validate_and_prepare_params(:shortUrl => delete_url_schema(self.short_url))
        response = post(EXPAND_URL, params)

        @long_url = response['url']
      end

      private

      def validate_and_prepare_params(params={})
        params = params_for_request(params)

        params.each_pair do |k, v|
          validate(k, params)
        end

        params
      end
      
      def params_for_request(params={})
        base_params = { :key => self.class.api_key }
        base_params.merge!(params)
      end
      
      def delete_url_schema(url)
        url.gsub(/^\w+:\/\//, '')
      end

      def prepend_url_schema(url)
        "http://#{ url }"
      end

      def validate(key, hash={})
        if hash[key].nil? || hash[key].empty?
          raise "Key :#{key} missing from request parameters!"
        end
      end
    end
  end
end
