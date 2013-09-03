module Neteasy
  module UrlShortener
    class UrlShortenerError < StandardError
      attr_reader :data
      
      def initialize(data)
        self.data = data
        super
      end
    end
    
    class MissingApiKey < UrlShortenerError; end
  end
end
