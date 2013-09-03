module Neteasy
  module UrlShortener
    module Request
      def post(url, params={})
        response = Net::HTTP.post_form URI(url), format_params(params)
        parse(response.body)
      end

      private

      def parse(response)
        JSON.parse(response)
      end

      def format_params(params={})
        params
      end
    end
  end
end
