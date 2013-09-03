# encoding: utf-8
# 请创建 Neteasy api key，以启用 short url service

neteasy_url_shortener_config = YAML.load_file("#{Rails.root}/config/neteasy_url_shortener.yml")
Neteasy::UrlShortener::Base.api_key = neteasy_url_shortener_config['api_key']
