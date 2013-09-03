module Neteasy
  module UrlShortener
    class Base
      class << self

        def api_key=(key)
          @@api_key = key
        end
        
        def api_key
          begin
            @@api_key
          rescue NameError
            raise MissingApiKey, "No API key has been set!"
          end
        end
      end
    end # /Base
  end
end
